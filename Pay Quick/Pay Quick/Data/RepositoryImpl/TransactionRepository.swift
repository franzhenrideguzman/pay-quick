//
//  TransactionRepository.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 3/31/26.
//

import Foundation

final class TransactionRepository: TransactionRepositoryProtocol {

    private let apiClient: APIClientProtocol
    private let keychain: KeychainServiceProtocol

    init(apiClient: APIClientProtocol, keychain: KeychainServiceProtocol) {
        self.apiClient = apiClient
        self.keychain = keychain
    }

    func fetchTransactions(page: Int) async throws -> PaginatedTransactions {
        guard let accessToken = keychain.load(.accessToken) else {
            throw NetworkError.unauthorized
        }

        let endpoint = PayQuickEndpoint.GetTransactions(
            accessToken: accessToken,
            page: page
        )
        let response: TransactionResponse = try await apiClient.perform(endpoint)
        return response.toDomain()
    }
}
