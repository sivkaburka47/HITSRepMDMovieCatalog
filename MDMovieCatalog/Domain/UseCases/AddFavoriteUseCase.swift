//
//  AddFavoriteUseCase.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 31.10.2024.
//

import Foundation

protocol AddFavoriteUseCase {
    func execute(token: String, movieId: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class AddFavoriteUseCaseImpl: AddFavoriteUseCase {
    
    private let repository: MovieRepository
    
    init(repository: MovieRepository) {
        self.repository = repository
    }
    
    func execute(token: String, movieId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        repository.addFavorite(token: token, movieId: movieId, completion: completion)
    }
}
