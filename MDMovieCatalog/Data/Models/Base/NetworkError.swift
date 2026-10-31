//
//  NetworkError.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(statusCode: HTTPStatusCode, data: Data?)
    case decodingFailed(Error)
    case unknown(Error)
}
