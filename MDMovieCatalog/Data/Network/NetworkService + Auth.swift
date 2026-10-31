//
//  NetworkService + Auth.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

extension NetworkService: AuthNetworkProtocol {
    func login(
        credentials: LoginCredentials,
        completion: @escaping (Result<AuthResponse, NetworkServiceError>) -> Void
    ) {
        let endpoint = AuthEndpoint.login(credentials: credentials)
        
        request(endpoint: endpoint) { (result: Result<AuthResponse, NetworkServiceError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(.unknown(error)))
            }
        }
    }
    
    func register(
        data: UserRegisterModel,
        completion: @escaping (Result<AuthResponse, NetworkServiceError>) -> Void
    ) {
        let endpoint = AuthEndpoint.register(data: data)
        
        request(endpoint: endpoint) { (result: Result<AuthResponse, NetworkServiceError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(.unknown(error)))
            }
        }
    }
    
    func logout(completion: @escaping (Result<Void, NetworkServiceError>) -> Void) {
        let endpoint = AuthEndpoint.logout
        
        requestWithoutResponse(endpoint: endpoint) { (result: Result<Void, NetworkServiceError>) in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(.unknown(error)))
            }
        }
    }
}
