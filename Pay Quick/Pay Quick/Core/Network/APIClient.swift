//
//  APIClient.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 3/30/26.
//

import Foundation

// MARK: - APIClientProtocol

protocol APIClientProtocol {
    func perform<T: Decodable>(_ endpoint: any Endpoint) async throws -> T
}

// MARK: - APIClient

final class APIClient: APIClientProtocol {

    private let session: URLSession
    private let decoder: JSONDecoder
    private let refreshInterceptor: TokenRefreshInterceptor

    init(
        session: URLSession = .shared,
        refreshInterceptor: TokenRefreshInterceptor
    ) {
        self.session = session
        self.refreshInterceptor = refreshInterceptor

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Core Request

    func perform<T: Decodable>(_ endpoint: any Endpoint) async throws -> T {
        let request = try endpoint.makeURLRequest()
        return try await execute(request: request, isRetry: false)
    }

    // MARK: - Private

    private func execute<T: Decodable>(request: URLRequest, isRetry: Bool) async throws -> T {
        print("🌐 Request URL: \(request.url?.absoluteString ?? "nil")")
        let (data, response) = try await fetchData(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(URLError(.badServerResponse))
        }
        
        print("📡 Status Code: \(httpResponse.statusCode)")
        print("📦 Response: \(String(data: data, encoding: .utf8) ?? "nil")")

        switch httpResponse.statusCode {
        case 200..<300:
            return try decode(T.self, from: data)

        case 401:
            guard !isRetry else {
                throw NetworkError.sessionExpired
            }
            let refreshedRequest = try await refreshInterceptor.refreshAndRetry(original: request)
            return try await execute(request: refreshedRequest, isRetry: true)

        default:
            let message = try? decode(APIErrorResponse.self, from: data)
            throw NetworkError.serverError(
                statusCode: httpResponse.statusCode,
                message: message?.message
            )
        }
    }

    private func fetchData(for request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch let urlError as URLError where urlError.code == .notConnectedToInternet {
            throw NetworkError.noInternetConnection
        } catch {
            throw NetworkError.unknown(error)
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}

// MARK: - Supporting Types

private struct APIErrorResponse: Decodable {
    let message: String?
}
