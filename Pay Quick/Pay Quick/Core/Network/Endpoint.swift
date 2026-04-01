//
//  Endpoint.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 3/30/26.
//

import Foundation

// MARK: - HTTPMethod
enum HTTPMethod: String {
    case get  = "GET"
    case post = "POST"
}

// MARK: - Endpoint Protocol
protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var body: Encodable? { get }
    var queryItems: [URLQueryItem]? { get }
}

extension Endpoint {
    var queryItems: [URLQueryItem]? { nil }
    var body: Encodable? { nil }

    func makeURLRequest() throws -> URLRequest {
        var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = 30

        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        if let body {
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return request
    }
}

// MARK: - PayQuick API Endpoints
private let kbaseURL = URL(string: "http://localhost:3000")!

enum PayQuickEndpoint {
    struct Login: Endpoint {
        struct Body: Encodable {
            let email: String
            let password: String
        }
        let email: String
        let password: String

        var baseURL: URL { kbaseURL }
        var path: String { "/api/v1/login" }
        var method: HTTPMethod { .post }
        var headers: [String: String] { [:] }
        var body: Encodable? { Body(email: email, password: password) }
    }

    struct RefreshToken: Endpoint {
        struct Body: Encodable {
            let refresh_token: String
        }
        let accessToken: String
        let refreshToken: String

        var baseURL: URL { kbaseURL }
        var path: String { "/api/v1/token/refresh" }
        var method: HTTPMethod { .post }
        var headers: [String: String] {
            ["Authorization": "Bearer \(accessToken)"]
        }
        var body: Encodable? { Body(refresh_token: refreshToken) }
    }

    struct GetTransactions: Endpoint {
        let accessToken: String
        let page: Int

        var baseURL: URL { kbaseURL }
        var path: String { "/api/v1/transactions" }
        var method: HTTPMethod { .get }
        var headers: [String: String] {
            ["Authorization": "Bearer \(accessToken)"]
        }
        var queryItems: [URLQueryItem]? {
            [URLQueryItem(name: "page", value: "\(page)")]
        }
    }
}
