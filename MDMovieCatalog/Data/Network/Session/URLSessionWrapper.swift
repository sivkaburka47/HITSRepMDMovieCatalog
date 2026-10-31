//
//  URLSessionWrapper.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

final class URLSessionWrapper: NetworkSessionProtocol {
    private let session = URLSession.shared
    
    func data(
        for request: URLRequest,
        completion: @escaping (Result<(Data, HTTPURLResponse), NetworkError>) -> Void
    ) {
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(NetworkError.unknown(error)))
                return
            }
            
            guard let data = data, let response = response else {
                let error = NSError(
                    domain: "NetworkError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Нет данных или ответа"]
                
                )
                completion(.failure(.unknown(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let castError = NSError(
                    domain: "NetworkError", code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Неверный формат ответа"]
                )
                completion(.failure(.unknown(castError)))
                return
            }
            
            let status = HTTPStatusCode(rawValue: httpResponse.statusCode)
            
            guard status.isSuccess else {
                completion(.failure(.requestFailed(statusCode: status, data: data)))
                return
            }
            
            completion(.success((data, httpResponse)))
            return
            
        }.resume()
    }
}
