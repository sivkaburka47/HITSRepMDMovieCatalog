//
//  LoginUserUseCase.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 15.10.2024.
//

import Foundation

protocol LoginUserUseCaseProtocol {
    func execute(user: LoginCredentials, completion: @escaping (Result<String, Error>) -> Void)
}

class LoginUserUseCase: LoginUserUseCaseProtocol {
    private let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    func execute(user: LoginCredentials, completion: @escaping (Result<String, Error>) -> Void) {
        apiService.loginUser(user: user, completion: completion)
    }
}
