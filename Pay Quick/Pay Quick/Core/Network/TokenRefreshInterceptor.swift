//
//  TokenRefreshInterceptor.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 3/30/26.
//

import Foundation

// MARK: - TokenRefreshInterceptor
//
// Handles automatic token refresh when a 401 is received.
// Uses Swift actor to prevent multiple simultaneous refresh calls —
// if 3 requests fail at once, only ONE refresh is made, the others wait.

actor TokenRefreshInterceptor {

    // MARK: - Dependencies
    private let keychain: KeychainServiceProtocol
    private let session: URLSession

    // MARK: - Callback
    let onSessionExpired: @Sendable () -> Void

    // MARK: - State
    private var isRefreshing = false
    private var refreshContinuations: [CheckedContinuation<String, Error>] = []

    // MARK: - Init
    init(
        keychain: KeychainServiceProtocol,
        session: URLSession = .shared,
        onSessionExpired: @escaping @Sendable () -> Void
    ) {
        self.keychain = keychain
        self.session = session
        self.onSessionExpired = onSessionExpired
    }

    // MARK: - Public
    func refreshAndRetry(original request: URLRequest) async throws -> URLRequest {
        let newAccessToken = try await getValidAccessToken()
        return inject(token: newAccessToken, into: request)
    }

    // MARK: - Private

    private func getValidAccessToken() async throws -> String {
        if isRefreshing {
            return try await withCheckedThrowingContinuation { continuation in
                refreshContinuations.append(continuation)
            }
        }

        isRefreshing = true

        do {
            let newToken = try await performRefresh()
            resumeContinuations(with: .success(newToken))
            isRefreshing = false
            return newToken
        } catch {
            resumeContinuations(with: .failure(error))
            isRefreshing = false
            onSessionExpired()
            throw NetworkError.sessionExpired
        }
    }

    private func performRefresh() async throws -> String {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard
            let accessToken  = await keychain.load(.accessToken),
            let refreshToken = await keychain.load(.refreshToken)
        else {
            throw NetworkError.sessionExpired
        }

        let endpoint = PayQuickEndpoint.RefreshToken(
            accessToken: accessToken,
            refreshToken: refreshToken
        )
        let urlRequest = try await endpoint.makeURLRequest()
        let (data, response) = try await session.data(for: urlRequest)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw NetworkError.sessionExpired
        }

        let dto = try await MainActor.run {
            try decoder.decode(RefreshResponseDTO.self, from: data)
        }
        let newAccessToken  = dto.data.access_token
        let newRefreshToken = dto.data.refresh_token

        try? await keychain.save(newAccessToken,  for: .accessToken)
        try? await keychain.save(newRefreshToken, for: .refreshToken)

        return newAccessToken
    }

    private func inject(token: String, into request: URLRequest) -> URLRequest {
        var updated = request
        updated.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return updated
    }

    private func resumeContinuations(with result: Result<String, Error>) {
        let pending = refreshContinuations
        refreshContinuations = []
        pending.forEach { $0.resume(with: result) }
    }
}

// MARK: - DTO (private, only needed here)
nonisolated private struct RefreshResponseDTO: Decodable, Sendable {
    struct Data: Decodable, Sendable {
        let access_token: String
        let refresh_token: String
        let expires_in: Int
    }
    let data: Data
}
