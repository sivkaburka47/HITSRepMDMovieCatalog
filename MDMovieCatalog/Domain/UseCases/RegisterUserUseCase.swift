//
//  RegisterUserUseCase.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 15.10.2024.
//

import Foundation

protocol RegisterUserUseCaseProtocol {
    func execute(user: RegistrationCredentials, completion: @escaping (Result<String, Error>) -> Void)
}

class RegisterUserUseCase: RegisterUserUseCaseProtocol {
    private let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    func execute(user: RegistrationCredentials, completion: @escaping (Result<String, Error>) -> Void) {
        apiService.registerUser(user: user, completion: completion)
    }
}
