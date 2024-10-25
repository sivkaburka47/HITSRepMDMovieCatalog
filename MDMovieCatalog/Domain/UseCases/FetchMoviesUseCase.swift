//
//  FetchMoviesUseCase.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 24.10.2024.
//

import Foundation

protocol FetchMoviesUseCase {
    func execute(page: Int, completion: @escaping (Result<[Movie], Error>) -> Void)
}

class FetchMoviesUseCaseImpl: FetchMoviesUseCase {
    
    private let repository: MovieRepository
    
    init(repository: MovieRepository) {
        self.repository = repository
    }
    
    func execute(page: Int, completion: @escaping (Result<[Movie], Error>) -> Void) {
        repository.fetchMovies(page: page, completion: completion)
    }
}
