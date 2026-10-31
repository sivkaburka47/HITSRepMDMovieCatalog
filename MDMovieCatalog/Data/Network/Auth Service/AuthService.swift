//
//  AuthService.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

protocol AuthServiceProtocol: AnyObject {
    func login(credentials: LoginCredentials, completion: @escaping (Result<Void, NetworkServiceError>) -> Void)
    func register(data: UserRegisterModel, completion: @escaping (Result<Void, NetworkServiceError>) -> Void)
    func logout(completion: @escaping () -> Void)
    var isAuthenticated: Bool { get }
}

final class AuthService: TokenRefresher, AuthServiceProtocol {
    private let authService: AuthNetworkProtocol
    private let keychainService: KeyChainServiceProtocol
    
    private(set) var currentToken: String?
    
    private var isRefreshing = false
    private var pendingRefreshCompletions: [(Bool) -> Void] = []
    
    var isAuthenticated: Bool {
        return currentToken != nil
    }
    
    init(authService: AuthNetworkProtocol, keychainService: KeyChainServiceProtocol) {
        self.authService = authService
        self.keychainService = keychainService
        self.currentToken = keychainService.loadToken()
    }
    
    func login(credentials: LoginCredentials, completion: @escaping (Result<Void, NetworkServiceError>) -> Void) {
        authService.login(credentials: credentials) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.currentToken = response.token
                self.keychainService.saveToken(response.token)
                self.keychainService.saveCredentials(credentials)
                completion(.success(()))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func register(data: UserRegisterModel, completion: @escaping (Result<Void, NetworkServiceError>) -> Void) {
        authService.register(data: data) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.currentToken = response.token
                self.keychainService.saveToken(response.token)
                completion(.success(()))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func logout(completion: @escaping () -> Void) {
        authService.logout { [weak self] _ in
            guard let self = self else { return }
            
            self.currentToken = nil
            self.keychainService.deleteAll()
            completion()
        }
    }
    
    func refreshToken(completion: @escaping (Bool) -> Void) {
        if isRefreshing {
            pendingRefreshCompletions.append(completion)
            return
        }
        
        isRefreshing = true
        pendingRefreshCompletions.append(completion)
        
        guard let credentials = keychainService.loadCredentials() else {
            finishRefresh(success: false)
            return
        }
        
        authService.login(credentials: credentials) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.currentToken = response.token
                self.keychainService.saveToken(response.token)
                self.finishRefresh(success: true)
                
            case .failure:
                self.currentToken = nil
                self.keychainService.deleteAll()
                self.finishRefresh(success: false)
            }
        }
    }
    
    private func finishRefresh(success: Bool) {
        isRefreshing = false
        let completions = pendingRefreshCompletions
        pendingRefreshCompletions.removeAll()
        
        completions.forEach { $0(success) }
    }
}
