//
//  NetworkProtocols.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

protocol AuthNetworkProtocol {
    func login(
        credentials: LoginCredentials,
        completion: @escaping (Result<AuthResponse, NetworkServiceError>) -> Void
    )
    
    func register(
        data: UserRegisterModel,
        completion: @escaping (Result<AuthResponse, NetworkServiceError>) -> Void
    )
    
    func logout(completion: @escaping (Result<Void, NetworkServiceError>) -> Void)
}
