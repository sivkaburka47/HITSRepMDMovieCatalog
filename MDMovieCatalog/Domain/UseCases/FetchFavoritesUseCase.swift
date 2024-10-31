//
//  FetchFavoritesUseCase.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 31.10.2024.
//

import Foundation

protocol FetchFavoritesUseCase {
    func execute(token: String, completion: @escaping (Result<[Movie], Error>) -> Void)
}

class FetchFavoritesUseCaseImpl: FetchFavoritesUseCase {
    
    private let repository: MovieRepository
    
    init(repository: MovieRepository) {
        self.repository = repository
    }
    
    func execute(token: String, completion: @escaping (Result<[Movie], Error>) -> Void) {
        repository.fetchFavorites(token: token, completion: completion)
    }
}
