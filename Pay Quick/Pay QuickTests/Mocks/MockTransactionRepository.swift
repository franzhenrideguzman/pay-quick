//
//  MockTransactionRepository.swift
//  Pay QuickTests
//
//  Created by Franz Henri De Guzman on 4/1/26.
//

import Foundation
@testable import Pay_Quick

final class MockTransactionRepository: TransactionRepositoryProtocol {

    // MARK: - Control Properties
    var shouldFail = false
    var errorToThrow: Error = NetworkError.noInternetConnection
    var fetchCallCount = 0

    // MARK: - Stub Response
    var stubbedPages: [Int: PaginatedTransactions] = [
        1: PaginatedTransactions(
            transactions: [
                Transaction(id: "1", amountInCents: 5000,  currency: "USD", type: .transfer, status: .success, createdAt: Date.october2025, destinationId: "wal_001"),
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

    func fetchTransactions(page: Int) async throws -> PaginatedTransactions {
        fetchCallCount += 1
        if shouldFail { throw errorToThrow }
        return stubbedPages[page] ?? stubbedPages[1]!
    }
}

// MARK: - Date Helpers for Tests

extension Date {
    static let october2025   = Date.make(year: 2025, month: 10, day: 9)
    static let september2025 = Date.make(year: 2025, month: 9,  day: 9)
    static let august2025    = Date.make(year: 2025, month: 8,  day: 9)
    static let july2025      = Date.make(year: 2025, month: 7,  day: 9)

    static func make(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year  = year
        components.month = month
        components.day   = day
        return Calendar.current.date(from: components) ?? Date()
    }
}
