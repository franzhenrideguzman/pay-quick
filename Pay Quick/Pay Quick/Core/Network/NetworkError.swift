//
//  NetworkError.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 3/30/26.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case unauthorized
    case sessionExpired
    case serverError(statusCode: Int, message: String?)
    case decodingFailed(Error)
    case noInternetConnection
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .unauthorized:
            return "Your session has expired. Please log in again."
        case .sessionExpired:
            return "Your session has expired. Please log in again."
        case .serverError(let code, let message):
            return message ?? "Server error (\(code))."
        case .decodingFailed:
            return "Failed to process the server response."
        case .noInternetConnection:
            return "No internet connection. Please check your network."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
