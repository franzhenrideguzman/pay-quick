//
//  AuthRepository.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 3/31/26.
//

import Foundation

final class AuthRepository: AuthRepositoryProtocol {

    private let apiClient: APIClientProtocol
    private let keychain: KeychainServiceProtocol

    init(apiClient: APIClientProtocol, keychain: KeychainServiceProtocol) {
        self.apiClient = apiClient
        self.keychain = keychain
    }

    func login(email: String, password: String) async throws -> (user: User, accessToken: String, refreshToken: String) {
        let endpoint = PayQuickEndpoint.Login(email: email, password: password)
        let response: LoginResponse = try await apiClient.perform(endpoint)
        return response.toDomain()
    }
}
