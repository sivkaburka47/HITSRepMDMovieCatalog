//
//  APIService.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 15.10.2024.
//

import Foundation

protocol APIServiceProtocol {
    func registerUser(user: RegistrationCredentials, completion: @escaping (Result<String, Error>) -> Void)
    
    func loginUser(user: LoginCredentials, completion: @escaping (Result<String, Error>) -> Void)
}

class APIService: APIServiceProtocol {
    private let baseURL = "https://react-midterm.kreosoft.space/api"
    
    func registerUser(user: RegistrationCredentials, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/account/register") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(user)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
                return
            }
            
            do {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    completion(.failure(NSError(domain: errorResponse.errors.duplicateUserName?.errors.first?.errorMessage ?? "Unknown error", code: httpResponse.statusCode, userInfo: nil)))
                } else {
                    let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                    UserDefaults.standard.set(tokenResponse.token, forKey: "authToken")
                    print("Token: \(tokenResponse.token)")
                    completion(.success(tokenResponse.token))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func loginUser(user: LoginCredentials, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/account/login") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(user)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
                return
            }
            
            do {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    completion(.failure(NSError(domain: errorResponse.errors.duplicateUserName?.errors.first?.errorMessage ?? "Unknown error", code: httpResponse.statusCode, userInfo: nil)))
                } else {
                    let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                    UserDefaults.standard.set(tokenResponse.token, forKey: "authToken")
                    print("Token: \(tokenResponse.token)")
                    completion(.success(tokenResponse.token))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

struct TokenResponse: Codable {
    let token: String
}

struct ErrorResponse: Codable {
    let message: String
    let errors: Errors
}

struct Errors: Codable {
    let duplicateUserName: DuplicateUserName?
    
    enum CodingKeys: String, CodingKey {
        case duplicateUserName = "DuplicateUserName"
    }
}

struct DuplicateUserName: Codable {
    let errors: [ErrorDetail]
}

struct ErrorDetail: Codable {
    let errorMessage: String
}
