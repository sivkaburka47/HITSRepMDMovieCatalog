//
//  NetworkServiceErrorUtility.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

public enum NetworkErrorUtility {
    public static func isNoInternetError(_ error: Error) -> Bool {
        let nsError = error as NSError
        
        guard nsError.domain == NSURLErrorDomain else {
            if let networkError = error as? NetworkServiceError {
                return networkError.isNoInternet
            }
            return false
        }
        
        let urlErrorCode = URLError.Code(rawValue: nsError.code)
        
        switch urlErrorCode {
        case .notConnectedToInternet,
             .networkConnectionLost,
             .cannotConnectToHost,
             .cannotFindHost,
             .timedOut,
             .dataNotAllowed,
             .internationalRoamingOff,
             .callIsActive,
             .secureConnectionFailed,
             .cannotLoadFromNetwork:
            return true
        default:
            return false
        }
    }
}
