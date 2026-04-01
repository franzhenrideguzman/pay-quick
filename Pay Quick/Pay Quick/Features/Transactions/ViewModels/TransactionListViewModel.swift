//
//  TransactionListViewModel.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 3/31/26.
//

import Foundation
import Combine

// MARK: - TransactionSection
struct TransactionSection: Identifiable {
    let id: String
    let title: String
    let transactions: [Transaction]
}

// MARK: - TransactionListViewState
struct TransactionListViewState {
    var sections: [TransactionSection] = []
    var isLoadingFirstPage: Bool = false
    var isLoadingNextPage: Bool = false
    var errorMessage: String? = nil
    var currentPage: Int = 0
    var totalPages: Int = 1

    var hasNextPage: Bool { currentPage < totalPages }
    var isEmpty: Bool { sections.isEmpty && !isLoadingFirstPage }
}

// MARK: - TransactionListViewModel
@MainActor
final class TransactionListViewModel: ObservableObject {

    // MARK: - Published State
    @Published private(set) var viewState = TransactionListViewState()

    // MARK: - Dependencies
    private let transactionRepository: TransactionRepositoryProtocol
    private let appSession: AppSession

    // MARK: - Private State
    private var allTransactions: [Transaction] = []
    private var isFetching = false

    // MARK: - Init
    init(transactionRepository: TransactionRepositoryProtocol, appSession: AppSession) {
        self.transactionRepository = transactionRepository
        self.appSession = appSession
    }

    // MARK: - Intents
    func onAppear() {
        guard allTransactions.isEmpty else { return }
        loadFirstPage()
    }

    func loadFirstPage() {
        allTransactions = []
        viewState = TransactionListViewState()
        viewState.isLoadingFirstPage = true
        fetchPage(1)
    }

    /// Called when last row appears — triggers next page (infinite scroll)
    func onLastRowAppeared() {
        guard viewState.hasNextPage, !isFetching else { return }
        viewState.isLoadingNextPage = true
        fetchPage(viewState.currentPage + 1)
    }

    func logoutTapped() {
        appSession.signOut()
    }

    // MARK: - Private

    private func fetchPage(_ page: Int) {
        guard !isFetching else { return }
        isFetching = true

        Task {
            defer {
                isFetching = false
                viewState.isLoadingFirstPage = false
                viewState.isLoadingNextPage = false
            }

            do {
                let result = try await transactionRepository.fetchTransactions(page: page)

                allTransactions.append(contentsOf: result.transactions)
                viewState.currentPage  = result.currentPage
                viewState.totalPages   = result.totalPages
                viewState.errorMessage = nil
                viewState.sections     = buildSections(from: allTransactions)

            } catch {
                viewState.errorMessage = friendlyMessage(for: error)
            }
        }
    }

    /// Groups transactions into monthly sections, newest first
    private func buildSections(from transactions: [Transaction]) -> [TransactionSection] {
        var grouped: [String: [Transaction]] = [:]

        for txn in transactions {
            grouped[txn.monthGroupKey, default: []].append(txn)
        }

        return grouped
            .map { key, txns in
                TransactionSection(
                    id: key,
                    title: key,
                    transactions: txns.sorted { $0.createdAt > $1.createdAt }
                )
            }
            .sorted { lhs, rhs in
                let lhsDate = lhs.transactions.first?.createdAt ?? .distantPast
                let rhsDate = rhs.transactions.first?.createdAt ?? .distantPast
                return lhsDate > rhsDate
            }
    }

    private func friendlyMessage(for error: Error) -> String {
        (error as? NetworkError)?.errorDescription ?? error.localizedDescription
    }
}
