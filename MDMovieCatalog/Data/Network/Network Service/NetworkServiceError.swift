//
//  NetworkServiceError.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

enum NetworkServiceError: Error {
    case invalidURL
    case requestFailed(statusCode: HTTPStatusCode, data: Data?)
    case decodingFailed(Error)
    case unauthorized
    case noInternet
    case unknown(Error)
}

extension NetworkServiceError {
    var isNoInternet: Bool {
        if case .noInternet = self { return true }
        return false
    }
}
