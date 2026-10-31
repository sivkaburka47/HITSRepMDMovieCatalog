//
//  NetworkSessionProtocol.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

protocol NetworkSessionProtocol {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<(Data, HTTPURLResponse), NetworkServiceError>) -> Void
    )
}
