//
//  MoviesViewModel.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 28.10.2024.
//

import Foundation

class MoviesViewModel {
    private var currentPage: Int = 2
    private var allMovies: [Movie] = []
    private var moviesCarousel: [Movie] = []
    private var moviesFavoritesCarousel: [Movie] = []
    private var carouselPage: Int = 1
    private let fetchMoviesUseCase: FetchMoviesUseCase
    private let fetchFavoritesUseCase: FetchFavoritesUseCase
    
    private var appRouter: AppRouter
    
    init(appRouter: AppRouter, fetchMoviesUseCase: FetchMoviesUseCase = FetchMoviesUseCaseImpl(repository: MovieRepositoryImpl()),
         fetchFavoritesUseCase: FetchFavoritesUseCase = FetchFavoritesUseCaseImpl(repository: MovieRepositoryImpl())) {
        self.appRouter = appRouter
        self.fetchMoviesUseCase = fetchMoviesUseCase
        self.fetchFavoritesUseCase = fetchFavoritesUseCase
    }
    
    func fetchMoviesForCarousel(completion: @escaping () -> Void) {
        fetchMoviesUseCase.execute(page: carouselPage) { [weak self] result in
            switch result {
            case .success(let movies):
                self?.moviesCarousel = movies
            case .failure(let error):
                if let nsError = error as NSError?, nsError.domain == "Unauthorized", nsError.code == 401 {
                    DispatchQueue.main.async {
                        self?.logOut()
                    }
                    return
                } else {
                    print("Error fetching movies: \(error)")
                }
            }
            completion()
        }

    }
    
    func fetchFavorites(completion: @escaping () -> Void) {
        let token = UserDefaults.standard.string(forKey: "authToken") ?? ""
        fetchFavoritesUseCase.execute(token: token) { [weak self] result in
            switch result {
            case .success(let movies):
                self?.moviesFavoritesCarousel = movies
            case .failure(let error):
                if let nsError = error as NSError?, nsError.domain == "Unauthorized", nsError.code == 401 {
                    DispatchQueue.main.async {
                        self?.logOut()
                    }
                    return
                } else {
                    print("Error fetching movies: \(error)")
                }
            }
            completion()
        }
        print("фетч фавориты")
    }
    
    func getCurrentMovieForCarousel(index: Int) -> Movie? {
        return moviesCarousel[index]
    }
    
    func getMoviesForFavoritesCarousel() -> [Movie] {
        for movie in moviesFavoritesCarousel {
            print(movie.title)
        }
        return moviesFavoritesCarousel
    }
    
    
    
    
    func fetchAllMovies(completion: @escaping () -> Void) {
        guard currentPage <= 5 else {
            completion()
            return
        }
        print("fetchAllMovies\(currentPage)")
        
        fetchMoviesUseCase.execute(page: currentPage) { [weak self] result in
            switch result {
            case .success(let movies):
                var updatedMovies: [Movie] = []
                for var movie in movies {
                    if let favorites = self?.moviesFavoritesCarousel, !favorites.isEmpty {
                        if let _ = favorites.first(where: { $0.id == movie.id }) {
                            movie.isFavorite = true
                        }
                    }
                    updatedMovies.append(movie)
                }
                self?.allMovies.append(contentsOf: updatedMovies)
                self?.currentPage += 1
            case .failure(let error):
                print("Error fetching all movies: \(error)")
            }
            completion()
        }
    }
    
    func loadNextPageIfNeeded(currentIndex: Int, completion: @escaping () -> Void) {
        if currentIndex >= allMovies.count - 1 && currentPage <= 5 {
            fetchAllMovies {
                completion()
            }
        }
    }
    
    func getAllMovies() -> [Movie] {
        return allMovies
    }
    
    func logOut() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        appRouter.start()
    }

}
