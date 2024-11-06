//
//  DetailsViewModel.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 02.11.2024.
//

import Foundation

class DetailsViewModel: ObservableObject {
    @Published var profile: ProfileModel?
    @Published var filmKinopoisk: FilmItemKinoPoisk?
    @Published var movieDetails: MovieDetails?
    @Published var director: PersonItemKinopoisk?
    @Published var averageRating: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isFavorite: Bool = false
    @Published var favorites: [Movie] = []
    @Published var haveReview: Bool = false
    @Published var rating: Double = 5.0
    @Published var reviewText: String = ""
    @Published var isAnonymous: Bool = false
    @Published var isReviewWritten: Bool = false
    @Published var reviewId: String = ""
    
    
    private let deleteFavoriteUseCase: DeleteFavoriteUseCase
    private let addFavoriteUseCase: AddFavoriteUseCase
    private let fetchFavoritesUseCase: FetchFavoritesUseCase
    private var appRouter: AppRouter
    
    init(appRouter: AppRouter, fetchFavoritesUseCase: FetchFavoritesUseCase = FetchFavoritesUseCaseImpl(repository: MovieRepositoryImpl()),
    addFavoriteUseCase: AddFavoriteUseCase = AddFavoriteUseCaseImpl(repository: MovieRepositoryImpl()),
         deleteFavoriteUseCase: DeleteFavoriteUseCase = DeleteFavoriteUseCaseImpl(repository: MovieRepositoryImpl())) {
        self.appRouter = appRouter
        self.fetchFavoritesUseCase = fetchFavoritesUseCase
        self.addFavoriteUseCase = addFavoriteUseCase
        self.deleteFavoriteUseCase = deleteFavoriteUseCase
    }
    
    func addToFavorites() {
        let id = movieDetails?.id ?? ""
        let token = UserDefaults.standard.string(forKey: "authToken") ?? ""
        addFavoriteUseCase.execute(token: token, movieId: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.isFavorite = true
                case .failure(let error):
                    print("Failed to decode JSON: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteFromFavorites() {
        let id = movieDetails?.id ?? ""
        let token = UserDefaults.standard.string(forKey: "authToken") ?? ""
        deleteFavoriteUseCase.execute(token: token, movieId: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.isFavorite = false
                case .failure(let error):
                    print("Failed to decode JSON: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchFavorites(id: String) {
        let token = UserDefaults.standard.string(forKey: "authToken") ?? ""
        isLoading = true
        errorMessage = nil
        
        fetchFavoritesUseCase.execute(token: token) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let favorites):
                    self.favorites = favorites
                    if let currentMovieId = self.movieDetails?.id {
                        self.isFavorite = self.isMovieInFavorites(movieId: currentMovieId)
                    }
                case .failure(let error):
                    if let nsError = error as NSError?, nsError.domain == "Unauthorized", nsError.code == 401 {
                        self.appRouter.logout()
                    } else {
                        print("Failed to decode JSON: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func isMovieInFavorites(movieId: String) -> Bool {
        return favorites.contains { $0.id == movieId }
    }
    
    func fetchProfile() {

        let token = UserDefaults.standard.string(forKey: "authToken") ?? ""
        guard let url = URL(string: "https://react-midterm.kreosoft.space/api/account/profile") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            
            let statusCode = httpResponse.statusCode
            print("Status Code: \(statusCode)")
            
            if statusCode == 401 {
                DispatchQueue.main.async {
                    self?.appRouter.logout()
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                var profile = try JSONDecoder().decode(ProfileModel.self, from: data)
                profile.birthDate = "Invalid date"
                self?.profile = profile
                
                DispatchQueue.main.async {
                    print("id: \(profile.id), nickName: \(profile.nickName), email: \(profile.email), avatar: \(profile.avatarLink), name: \(profile.name), birthDate: \(profile.birthDate), gender: \(profile.gender)")
                    if let reviews = self?.movieDetails?.reviews {
                        for review in reviews {
                            if review.author.userId == profile.id {
                                print("ИМЕЕЕЕЕЕЕТСЯ")
                                self?.isReviewWritten = true
                                self?.reviewText = review.reviewText ?? ""
                                self?.isAnonymous = review.isAnonymous
                                self?.rating = Double(review.rating)
                                self?.reviewId = review.id
                            }
                        }
                    }
                }
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
        }
        
        task.resume()

    }
    
    func fetchMovieDetails(id: String) {
        print(id)
        let token = UserDefaults.standard.string(forKey: "authToken") ?? ""
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "https://react-midterm.kreosoft.space/api/movies/details/\(id)") else {
            print("Неверный URL")
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    print("Failed to decode JSON: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    self.movieDetails = try decoder.decode(MovieDetails.self, from: data)
                    if let reviews = self.movieDetails?.reviews, !reviews.isEmpty {
                        let totalRating = reviews.reduce(0) { $0 + $1.rating }
                        let averageRatingDouble = (Double(totalRating) / Double(reviews.count)) * 10
                        let roundedAverageRating = averageRatingDouble.rounded() / 10
                        self.averageRating = String(format: "%.1f", roundedAverageRating)
                        self.fetchFavorites(id: id)
                        self.fetchMovieDetailsFromKinopoisk()
                        self.fetchProfile()
                    }
                } catch {
                    print("Failed to decode JSON: \(error.localizedDescription)")
                }
            }
        }
        task.resume()

    }
    
    func fetchMovieDetailsFromKinopoisk() {
        guard let movieName = movieDetails?.name else {
            print("Имя фильма не найдено")
            return
        }
        
        let encodedMovieName = movieName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://kinopoiskapiunofficial.tech/api/v2.2/films?order=RATING&type=ALL&ratingFrom=0&ratingTo=10&yearFrom=1000&yearTo=3000&keyword=\(encodedMovieName)&page=1"
        
        guard let url = URL(string: urlString) else {
            print("Неверный URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("ab58aa45-d0fc-4728-a4a0-f26263e5607f", forHTTPHeaderField: "X-API-KEY")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("\(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let filmKinopoisk = try decoder.decode(FilmKinopoisk.self, from: data)
                    self.filmKinopoisk = filmKinopoisk.items.first
                    self.fetchPersonFromKinopoisk()
                } catch {
                    print("Failed to decode JSON: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
    }
    
    func fetchPersonFromKinopoisk() {
        guard let personName = movieDetails?.director else {
            print("Имя режиссера не найдено")
            return
        }
        
        let encodedPersonName = personName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://kinopoiskapiunofficial.tech/api/v1/persons?name=\(encodedPersonName)&page=1"
        
        guard let url = URL(string: urlString) else {
            print("Неверный URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("ab58aa45-d0fc-4728-a4a0-f26263e5607f", forHTTPHeaderField: "X-API-KEY")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("\(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let personKinopoisk = try decoder.decode(PersonByNameKinopoisk.self, from: data)
                    self.director = personKinopoisk.items.first
                } catch {
                    print("Failed to decode JSON: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
    }
    
    func toggleFavorite() {
        if isFavorite == false {
            addToFavorites()
        } else if isFavorite == true {
            deleteFromFavorites()
        }
    }
    
    func didTapDeleteReview(movieId: String){
        deleteReview(movieId: movieId, reviewId: reviewId) { result in
            switch result {
            case .success(let data):
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteReview(movieId: String, reviewId: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: "https://react-midterm.kreosoft.space/api/movie/\(movieId)/review/\(reviewId)/delete") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
    }
    
    
    func didTapEditReview(movieId: String) {
        let review = ReviewMD(reviewText: reviewText, rating: Int(rating), isAnonymous: isAnonymous)
        editReview(movieId: movieId, review: review) { result in
            switch result {
            case .success(let data):
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func editReview(movieId: String, review: ReviewMD, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: "https://react-midterm.kreosoft.space/api/movie/\(movieId)/review/\(reviewId)/edit") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let jsonData = try JSONEncoder().encode(review)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
    }
    
    
    func didTapAddReview(movieId: String) {
        let review = ReviewMD(reviewText: reviewText, rating: Int(rating), isAnonymous: isAnonymous)
        addReview(movieId: movieId, review: review) { result in
            switch result {
            case .success(let data):
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func addReview(movieId: String, review: ReviewMD, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: "https://react-midterm.kreosoft.space/api/movie/\(movieId)/review/add") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let jsonData = try JSONEncoder().encode(review)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
    }
    
    func addFriend(author: Author, idMovie: String, rating: Int) {
        let friend = Friend(userId: author.userId, nickName: author.nickName ?? "", avatar: author.avatar, moviesID: idMovie, rating: rating)
        
        var friends: [Friend] = []
        if let savedFriendsData = UserDefaults.standard.data(forKey: "Friends"),
           let savedFriends = try? JSONDecoder().decode([Friend].self, from: savedFriendsData) {
            friends = savedFriends
        }
        
        let existingFriend = friends.first { $0.userId == author.userId && $0.moviesID == idMovie }
        if existingFriend == nil {
            friends.append(friend)
            
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(friends) {
                UserDefaults.standard.set(encoded, forKey: "Friends")
            }
        }
    }
    
    func getFriendCount(forMovieId movieId: String, withRatingGreaterThan rating: Int = 5) -> Int {
        if let savedFriendsData = UserDefaults.standard.data(forKey: "Friends"),
           let savedFriends = try? JSONDecoder().decode([Friend].self, from: savedFriendsData) {
            let friendsForMovie = savedFriends.filter { $0.moviesID == movieId && $0.rating > rating }
            return friendsForMovie.count
        }
        return 0
    }
}

