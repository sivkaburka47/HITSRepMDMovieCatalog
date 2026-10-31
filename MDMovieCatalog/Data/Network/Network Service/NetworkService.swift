//
//  NetworkService.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

final class NetworkService {
    weak var tokenRefresher: TokenRefresher?
    
    private let session: NetworkSessionProtocol
    private let host: APIHost
    
    private let decoder = JSONDecoder()
    
    init(
        host: APIHost,
        session: NetworkSessionProtocol
    ) {
        self.host = host
        self.session = session
    }
    
    func request<T: Decodable>(
        endpoint: Endpoint,
        completion: @escaping (Result<T, NetworkServiceError>) -> Void
    ) {
        performRequest(endpoint: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let (data, _)):
                do {
                    let decodedResult = try self.decode(data, to: T.self)
                    completion(.success(decodedResult))
                } catch let error as NetworkServiceError {
                    completion(.failure(error))
                } catch {
                    completion(.failure(.unknown(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func requestWithoutResponse(
        endpoint: Endpoint,
        completion: @escaping (Result<Void, NetworkServiceError>) -> Void
    ) {
        performRequest(endpoint: endpoint) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}

extension NetworkService {
    private func performRequest(
        endpoint: Endpoint,
        completion: @escaping (Result<(Data, HTTPURLResponse), NetworkServiceError>) -> Void
    ) {
        let request: URLRequest
        do {
            request = try makeRequest(endpoint: endpoint)
        } catch let error as NetworkServiceError {
            completion(.failure(error))
            return
        } catch {
            completion(.failure(.unknown(error)))
            return
        }
        
        session.data(for: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let (data, response)):
                completion(.success((data, response)))
                
            case .failure(let error):
                if case .requestFailed(let status, let data) = error, status == .unauthorized {
                    if endpoint is AuthEndpointProtocol {
                        completion(.failure(.unauthorized))
                        return
                    }
                    
                    self.tokenRefresher?.refreshToken { [weak self] success in
                        guard let self = self else { return }
                        if success {
                            self.performRequest(endpoint: endpoint, completion: completion)
                        } else {
                            completion(.failure(.unauthorized))
                        }
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func makeRequest(endpoint: Endpoint) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host.host
        components.path = endpoint.path.hasPrefix("/") ? endpoint.path : "/" + endpoint.path
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url else {
            throw NetworkServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        let currentToken = tokenRefresher?.currentToken ?? ""
        var headers = host.baseHeaders(token: currentToken)

        if let endpointHeaders = endpoint.headers {
            headers.merge(endpointHeaders) { _, new in new }
        }
        
        request.allHTTPHeaderFields = headers
        request.httpBody = endpoint.body
        
        return request
    }
    
    private func decode<T: Decodable>(_ data: Data, to type: T.Type) throws -> T {
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw NetworkServiceError.decodingFailed(error)
        }
    }
}
