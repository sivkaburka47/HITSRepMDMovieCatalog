//
//  AuthEndpoint.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

enum AuthEndpoint: Endpoint, AuthEndpointProtocol {
    case login(credentials: LoginCredentials)
    case register(data: UserRegisterModel)
    case logout

    var path: String {
        switch self {
        case .login:
            return "/api/auth/login"
        case .register:
            return "/api/auth/register"
        case .logout:
            return "/api/auth/logout"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .register, .logout:
            return .post
        }
    }

    var queryItems: [URLQueryItem]? {
        return nil
    }

    var headers: [String: String]? {
        return nil
    }

    var body: Data? {
        switch self {
        case .login(let credentials):
            return try? JSONEncoder().encode(credentials)
        case .register(let data):
            return try? JSONEncoder().encode(data)
        case .logout:
            return nil
        }
    }
}
