//
//  DeleteFavoriteUseCase.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 03.11.2024.
//

import Foundation

protocol DeleteFavoriteUseCase {
    func execute(token: String, movieId: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class DeleteFavoriteUseCaseImpl: DeleteFavoriteUseCase {
    
    private let repository: MovieRepository
    
    init(repository: MovieRepository) {
        self.repository = repository
    }
    
    func execute(token: String, movieId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        repository.deleteFavorite(token: token, movieId: movieId, completion: completion)
    }
}
