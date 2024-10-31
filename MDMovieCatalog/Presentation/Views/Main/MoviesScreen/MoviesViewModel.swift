//
//  MoviesViewModel.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 28.10.2024.
//

import Foundation

class MoviesViewModel {
    private var moviesCarousel: [Movie] = []
    private var moviesFavoritesCarousel: [Movie] = []
    private var carouselPage: Int = 1
    private let fetchMoviesUseCase: FetchMoviesUseCase
    private let fetchFavoritesUseCase: FetchFavoritesUseCase
    
    init(fetchMoviesUseCase: FetchMoviesUseCase = FetchMoviesUseCaseImpl(repository: MovieRepositoryImpl()),
         fetchFavoritesUseCase: FetchFavoritesUseCase = FetchFavoritesUseCaseImpl(repository: MovieRepositoryImpl())) {
        self.fetchMoviesUseCase = fetchMoviesUseCase
        self.fetchFavoritesUseCase = fetchFavoritesUseCase
    }
    
    func fetchMoviesForCarousel(completion: @escaping () -> Void) {
        fetchMoviesUseCase.execute(page: carouselPage) { [weak self] result in
            switch result {
            case .success(let movies):
                self?.moviesCarousel = movies
            case .failure(let error):
                print("Error fetching movies: \(error)")
            }
            completion()
        }
        print("Загрузка movie для карусели закончена")
    }
    
    func fetchFavorites(completion: @escaping () -> Void) {
        let token = UserDefaults.standard.string(forKey: "authToken") ?? ""
        fetchFavoritesUseCase.execute(token: token) { [weak self] result in
            switch result {
            case .success(let movies):
                self?.moviesFavoritesCarousel = movies
            case .failure(let error):
                print("Error fetching favorites: \(error)")
            }
            completion()
        }
        print("Загрузка избранных фильмов закончена")
    }
    
    func getCurrentMovieForCarousel(index: Int) -> Movie? {
        return moviesCarousel[index]
    }
    
    func getMoviesForFavoritesCarousel() -> [Movie] {
        print("getMoviesForFavoritesCarousel")
        for movie in moviesFavoritesCarousel {
            print(movie.title)
        }
        return moviesFavoritesCarousel
    }
}
