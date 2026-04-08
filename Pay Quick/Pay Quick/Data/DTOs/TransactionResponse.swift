//
//  TransactionResponse.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 3/31/26.
//

import Foundation
struct TransactionResponse: Decodable {

    struct Pagination: Decodable {
        let current_page: Int
        let total_pages: Int
        let total_items: Int
        let items_per_page: Int
    }

    struct TransactionItem: Decodable {
        let id: String
        let amount_in_cents: Int
        let currency: String
        let type: String
        let status: String
        let created_at: Date
        let destination_id: String
    }

    let status: String
    let message: String
    let pagination: Pagination
    let data: [TransactionItem]
}

// MARK: - Mapping to Domain
extension TransactionResponse {
    func toDomain() -> PaginatedTransactions {
        let transactions = data.map { item -> Transaction in
            Transaction(
                id: item.id,
                amountInCents: item.amount_in_cents,
                currency: item.currency,
                type: TransactionType(rawValue: item.type) ?? .transfer,
                status: TransactionStatus(rawValue: item.status) ?? .unknown,
                createdAt: item.created_at,
                destinationId: item.destination_id
            )
        }

        return PaginatedTransactions(
            transactions: transactions,
            currentPage: pagination.current_page,
            totalPages: pagination.total_pages,
            totalItems: pagination.total_items
        )
    }
}
