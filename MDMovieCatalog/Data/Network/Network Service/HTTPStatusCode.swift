//
//  HTTPStatusCode.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

public enum HTTPStatusCode: RawRepresentable, Equatable {
    // 2xx Success
    case okStatus
    case created
    case accepted
    case noContent
    
    // 4xx Client Error
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case methodNotAllowed
    case conflict
    
    // 5xx Server Error
    case internalServerError
    case badGateway
    case serviceUnavailable
    case gatewayTimeout
    
    case unknown(Int)
    
    public init(rawValue: Int) {
        switch rawValue {
        case 200: self = .okStatus
        case 201: self = .created
        case 202: self = .accepted
        case 204: self = .noContent
            
        case 400: self = .badRequest
        case 401: self = .unauthorized
        case 403: self = .forbidden
        case 404: self = .notFound
        case 405: self = .methodNotAllowed
        case 409: self = .conflict
            
        case 500: self = .internalServerError
        case 502: self = .badGateway
        case 503: self = .serviceUnavailable
        case 504: self = .gatewayTimeout
            
        default: self = .unknown(rawValue)
        }
    }
    
    public var rawValue: Int {
        switch self {
        case .okStatus: return 200
        case .created: return 201
        case .accepted: return 202
        case .noContent: return 204
            
        case .badRequest: return 400
        case .unauthorized: return 401
        case .forbidden: return 403
        case .notFound: return 404
        case .methodNotAllowed: return 405
        case .conflict: return 409
            
        case .internalServerError: return 500
        case .badGateway: return 502
        case .serviceUnavailable: return 503
        case .gatewayTimeout: return 504
            
        case .unknown(let code): return code
        }
    }
    
    public var isSuccess: Bool {
        return (200...299).contains(rawValue)
    }
}
