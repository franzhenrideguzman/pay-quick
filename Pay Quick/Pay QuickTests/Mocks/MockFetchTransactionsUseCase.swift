//
//  MockFetchTransactionsUseCase.swift
//  Pay QuickTests
//
//  Created by Franz Henri De Guzman on 4/9/26.
//

import Foundation
@testable import Pay_Quick

final class MockFetchTransactionsUseCase: FetchTransactionsUseCaseProtocol {

    var shouldFail = false
    var errorToThrow: Error = NetworkError.noInternetConnection
    var executeCallCount = 0

    var stubbedPages: [Int: PaginatedTransactions] = [
        1: PaginatedTransactions(
            transactions: [
                Transaction(id: "1", amountInCents: 5000,  currency: "USD", type: .transfer, status: .success, createdAt: Date.october2025,   destinationId: "wal_001"),
                Transaction(id: "2", amountInCents: 10000, currency: "USD", type: .topUp,    status: .success, createdAt: Date.september2025, destinationId: "wal_002"),
            ],
            currentPage: 1, totalPages: 2, totalItems: 4
        ),
        2: PaginatedTransactions(
            transactions: [
                Transaction(id: "3", amountInCents: 3000, currency: "USD", type: .transfer, status: .success, createdAt: Date.august2025, destinationId: "wal_003"),
                Transaction(id: "4", amountInCents: 8000, currency: "USD", type: .topUp,    status: .success, createdAt: Date.july2025,   destinationId: "wal_004"),
            ],
            currentPage: 2, totalPages: 2, totalItems: 4
        )
    ]

    func execute(page: Int) async throws -> PaginatedTransactions {
        executeCallCount += 1
        if shouldFail { throw errorToThrow }
        return stubbedPages[page] ?? stubbedPages[1]!
    }
}
