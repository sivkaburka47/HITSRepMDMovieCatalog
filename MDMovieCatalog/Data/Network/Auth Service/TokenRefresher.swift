//
//  TokenRefresher.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

protocol TokenRefresher: AnyObject {
    func refreshToken(completion: @escaping (Bool) -> Void)
    var currentToken: String? { get }
}
