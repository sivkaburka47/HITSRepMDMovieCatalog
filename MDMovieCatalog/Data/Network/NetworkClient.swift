//
//  NetworkClient.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

final class NetworkClient {
    private let session: NetworkSessionProtocol
    private let host: String
    private let token: String
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    init(host: String, token: String, session: NetworkSessionProtocol) {
        self.host = host
        self.token = token
        self.session = session
    }
    
    func request<T: Decodable>(
        endpoint: Endpoint,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        performRequest(endpoint: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let (data, _)):
                do {
                    let decodedResult = try self.decode(data, to: T.self)
                    completion(.success(decodedResult))
                } catch let error as NetworkError {
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
        completion: @escaping (Result<Void, NetworkError>) -> Void
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

extension NetworkClient {
    private func performRequest(
        endpoint: Endpoint,
        completion: @escaping (Result<(Data, HTTPURLResponse), NetworkError>) -> Void
    ) {
        let request: URLRequest
        do {
            request = try makeRequest(endpoint: endpoint)
        } catch let error as NetworkError {
            completion(.failure(error))
            return
        } catch {
            completion(.failure(.unknown(error)))
            return
        }
        
        session.data(for: request) { result in
            completion(result)
        }
    }
    
    private func makeRequest(endpoint: Endpoint) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = endpoint.path
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        var headers = endpoint.headers ?? [:]
        headers["Authorization"] = "Bearer \(token)"
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        request.httpBody = endpoint.body
        
        return request
    }
    
    private func decode<T: Decodable>(_ data: Data, to type: T.Type) throws -> T {
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}

