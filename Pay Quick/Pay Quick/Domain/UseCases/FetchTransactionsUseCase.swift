//
//  FetchTransactionsUseCase.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 4/8/26.
//

import Foundation

protocol FetchTransactionsUseCaseProtocol {
    func execute(page: Int) async throws -> PaginatedTransactions
}

final class FetchTransactionsUseCase: FetchTransactionsUseCaseProtocol {

    private let transactionRepository: TransactionRepositoryProtocol

    init(transactionRepository: TransactionRepositoryProtocol) {
        self.transactionRepository = transactionRepository
    }

    func execute(page: Int) async throws -> PaginatedTransactions {
        return try await transactionRepository.fetchTransactions(page: page)
    }
}
