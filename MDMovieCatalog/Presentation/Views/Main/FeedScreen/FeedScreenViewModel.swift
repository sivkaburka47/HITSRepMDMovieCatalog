//
//  FeedScreenViewModel.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 23.10.2024.
//

import Foundation

class FeedViewModel {
    
    // MARK: - Properties
    private var movies: [Movie] = []
    private var currentMovieIndex: Int = 0
    private var currentMoviePageIndex: Int = 0
    private let addFavoriteUseCase: AddFavoriteUseCase
    private let fetchMoviesUseCase: FetchMoviesUseCase
    private var isLoadingNextPage: Bool = false
    private var currentMovie: Movie?
    private var nextMovie: Movie?
    
    var updateUI: (() -> Void)?
    var showLoadingIndicator: (() -> Void)?
    var hideLoadingIndicator: (() -> Void)?
    
    private var appRouter: AppRouter
    
    // MARK: - Initialization
    init(appRouter: AppRouter, fetchMoviesUseCase: FetchMoviesUseCase = FetchMoviesUseCaseImpl(repository: MovieRepositoryImpl()),
         addFavoriteUseCase: AddFavoriteUseCase = AddFavoriteUseCaseImpl(repository: MovieRepositoryImpl())) {
        self.appRouter = appRouter
        self.fetchMoviesUseCase = fetchMoviesUseCase
        self.addFavoriteUseCase = addFavoriteUseCase
        loadMovies()
    }
    
    // MARK: - Public Methods
    func getCurrentMovie() -> Movie? {
        guard currentMovieIndex < movies.count else { return nil }
        
        
        return movies[currentMovieIndex]
    }
    
    func loadNextMovie() {
        currentMovie = movies[currentMovieIndex]

        if currentMovieIndex + 1 < movies.count {
            currentMovieIndex += 1
        } else {
            let lastMovie = movies.last
            if currentMoviePageIndex + 1 < 6 {
                currentMoviePageIndex += 1
                currentMovieIndex = 0
                loadNextPageMovies(lastMovie: lastMovie)
            } else {
                currentMoviePageIndex = 1
                currentMovieIndex = 0
                loadNextPageMovies(lastMovie: lastMovie)

            }
        }
        nextMovie = movies[currentMovieIndex]

    }
    
    func addToDislikeMovies() {
        var dislikedMovies = getDislikedMovies()
        if let currentMovie = currentMovie {
            let movieIdString = String(currentMovie.id)
            dislikedMovies.append(movieIdString)
            UserDefaults.standard.set(dislikedMovies, forKey: "dislikedMovies")
        }
        print("ADD TO DISLIKE MOVIE: \(currentMovie?.title)")
    }
    
    func addToFavorites(completion: @escaping (Result<Void, Error>) -> Void) {
        let token = UserDefaults.standard.string(forKey: "authToken") ?? ""
        if let currentMovie = currentMovie {
            let movieId = String(currentMovie.id)
            addFavoriteUseCase.execute(token: token, movieId: movieId, completion: completion)
        }
    }
    
    private func loadMovies() {
        self.currentMoviePageIndex = 1
        showLoadingIndicator?()
        fetchMoviesUseCase.execute(page: currentMoviePageIndex) { [weak self] result in
            switch result {
            case .success(let movies):
                self?.movies = self?.filterDislikedMovies(movies) ?? []
                self?.currentMovieIndex = 0
                DispatchQueue.main.async {
                    self?.updateUI?()

                }
            case .failure(let error):
                print("Error fetching movies: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadNextPageMovies(lastMovie: Movie?) {
        guard !isLoadingNextPage else { return }
        isLoadingNextPage = true
        showLoadingIndicator?()
        
        fetchMoviesUseCase.execute(page: currentMoviePageIndex) { [weak self] result in
            switch result {
            case .success(let movies):
                if let lastMovie = lastMovie {
                    self?.movies = [lastMovie] + (self?.filterDislikedMovies(movies) ?? [])
                } else {
                    self?.movies = self?.filterDislikedMovies(movies) ?? []
                }
                self?.currentMovieIndex = 0
                DispatchQueue.main.async {
                    self?.isLoadingNextPage = false
                    self?.hideLoadingIndicator?()
                    self?.updateUI?()

                }
            case .failure(let error):
                self?.isLoadingNextPage = false
                self?.hideLoadingIndicator?()
                print("Error fetching movies: \(error.localizedDescription)")
            }
        }
    }
    
    private func getDislikedMovies() -> [String] {
        return UserDefaults.standard.array(forKey: "dislikedMovies") as? [String] ?? []
    }
    
    private func filterDislikedMovies(_ movies: [Movie]) -> [Movie] {
        let dislikedMovies = getDislikedMovies()
        return movies.filter { movie in
            let movieIdString = String(movie.id)
            return !dislikedMovies.contains(movieIdString)
        }
    }
    
    func navigateToMovieDetails() {
        appRouter.navigateToDetails(idRandMovie: movies[currentMovieIndex].id)
    }
}
