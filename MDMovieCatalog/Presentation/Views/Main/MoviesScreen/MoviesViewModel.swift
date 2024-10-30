//
//  MoviesViewModel.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 28.10.2024.
//

import Foundation

class MoviesViewModel {
    private var moviesCarousel: [Movie] = []
    private var carouselPage: Int = 1
    private let fetchMoviesUseCase: FetchMoviesUseCase
    
    
    init(fetchMoviesUseCase: FetchMoviesUseCase = FetchMoviesUseCaseImpl(repository: MovieRepositoryImpl())) {
        self.fetchMoviesUseCase = fetchMoviesUseCase

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
    
    func getCurrentMovieForCarousel(index: Int) -> Movie? {
        return moviesCarousel[index]
    }
}
