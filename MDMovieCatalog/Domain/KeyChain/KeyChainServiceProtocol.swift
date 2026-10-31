//
//  KeyChainServiceProtocol.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 01.11.2026.
//

import Foundation

protocol KeyChainServiceProtocol {
    func saveToken(_ token: String)
    func loadToken() -> String?
    func saveCredentials(_ credentials: LoginCredentials)
    func loadCredentials() -> LoginCredentials?
    func deleteAll()
}
