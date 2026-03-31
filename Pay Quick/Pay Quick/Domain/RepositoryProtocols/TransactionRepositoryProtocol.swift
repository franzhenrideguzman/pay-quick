//
//  TransactionRepositoryProtocol.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 3/30/26.
//

import Foundation

protocol TransactionRepositoryProtocol {
    func fetchTransactions(page: Int) async throws -> PaginatedTransactions
}
