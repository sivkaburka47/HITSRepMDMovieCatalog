//
//  APIHost.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

enum APIHost {
    case kreosoft
    case kinopoisk
    
    var host: String {
        switch self {
        case .kreosoft:
            return "react-midterm.kreosoft.space"
        case .kinopoisk:
            return "kinopoiskapiunofficial.tech"
        }
    }
    
    func baseHeaders(token: String) -> [String: String] {
        switch self {
        case .kreosoft:
            return [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
        case .kinopoisk:
            return [
                "X-API-KEY": token,
                "Content-Type": "application/json"
            ]
        }
    }
}
