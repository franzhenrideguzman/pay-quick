//
//  Transaction.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 3/30/26.
//

import Foundation

// MARK: - Transaction (Domain Model)

struct Transaction: Identifiable, Equatable {
    let id: String
    let amountInCents: Int
    let currency: String
    let type: TransactionType
    let status: TransactionStatus
    let createdAt: Date
    let destinationId: String

    // MARK: - Computed Helpers

    /// Formatted amount e.g. "$50.00"
    var formattedAmount: String {
        let amount = Double(amountInCents) / 100.0
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: amount)) ?? "\(currency) \(amount)"
    }

    /// Month/year label used for grouping e.g. "October 2025"
    var monthGroupKey: String {
        createdAt.formatted(.dateTime.month(.wide).year())
    }
}

// MARK: - TransactionType

enum TransactionType: String, Equatable {
    case transfer = "TRANSFER"
    case topUp    = "TOPUP"

    var displayName: String {
        switch self {
        case .transfer: return "Transfer"
        case .topUp:    return "Top Up"
        }
    }
}

// MARK: - TransactionStatus

enum TransactionStatus: String, Equatable {
    case success = "SUCCESS"
    case pending = "PENDING"
    case failed  = "FAILED"
    case unknown
}

// MARK: - PaginatedTransactions

struct PaginatedTransactions {
    let transactions: [Transaction]
    let currentPage: Int
    let totalPages: Int
    let totalItems: Int

    var hasNextPage: Bool { currentPage < totalPages }
}
