//
//  TransactionListView.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 3/31/26.
//

import Foundation
import SwiftUI

struct TransactionListView: View {

    @ObservedObject var viewModel: TransactionListViewModel

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Transactions")
                .navigationBarTitleDisplayMode(.large)
                .toolbar { toolbarItems }
                .background(Color.pqBgLight.ignoresSafeArea())
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    // MARK: - Content States

    @ViewBuilder
    private var content: some View {
        if viewModel.viewState.isLoadingFirstPage {
            firstPageLoadingView
        } else if let error = viewModel.viewState.errorMessage,
                  viewModel.viewState.sections.isEmpty {
            errorView(message: error)
        } else if viewModel.viewState.isEmpty {
            emptyView
        } else {
            transactionList
        }
    }

    // MARK: - Transaction List

    private var transactionList: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                ForEach(viewModel.viewState.sections) { section in
                    Section {
                        sectionRows(section)
                    } header: {
                        sectionHeader(title: section.title)
                    }
                }

                paginationFooter
            }
        }
        .refreshable {
            viewModel.loadFirstPage()
        }
    }

    private func sectionRows(_ section: TransactionSection) -> some View {
        ForEach(Array(section.transactions.enumerated()), id: \.element.id) { index, transaction in
            VStack(spacing: 0) {
                TransactionRowView(transaction: transaction)

                if index < section.transactions.count - 1 {
                    Divider()
                        .padding(.leading, 74)
                }
            }
            .onAppear {
                if isLastTransaction(transaction) {
                    viewModel.onLastRowAppeared()
                }
            }
        }
    }

    // MARK: - Section Header

    private func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.pqCaptionBold)
                .foregroundStyle(Color.pqTextSecondary)
                .textCase(.uppercase)
                .kerning(0.8)
            Spacer()
        }
        .padding(.horizontal, PQSpacing.md)
        .padding(.vertical, PQSpacing.sm)
        .background(Color.pqBgLight)
    }

    // MARK: - Pagination Footer

    @ViewBuilder
    private var paginationFooter: some View {
        if viewModel.viewState.isLoadingNextPage {
            HStack {
                ProgressView()
                Text("Loading more…")
                    .font(.pqSubheadline)
                    .foregroundStyle(Color.pqTextSecondary)
            }
            .padding(PQSpacing.lg)
        } else if !viewModel.viewState.hasNextPage,
                  !viewModel.viewState.sections.isEmpty {
            Text("All transactions loaded")
                .font(.pqCaption)
                .foregroundStyle(Color.pqTextTertiary)
                .padding(PQSpacing.lg)
        }

        if let error = viewModel.viewState.errorMessage,
           !viewModel.viewState.sections.isEmpty {
            HStack(spacing: PQSpacing.sm) {
                Image(systemName: "exclamationmark.circle")
                    .foregroundStyle(Color.pqRed)
                Text(error)
                    .font(.pqSubheadline)
                    .foregroundStyle(Color.pqRed)
                Spacer()
                Button("Retry") {
                    viewModel.onLastRowAppeared()
                }
                .font(.pqHeadline)
                .foregroundStyle(Color.pqBlue)
            }
            .padding(PQSpacing.md)
            .background(Color.pqRed.opacity(0.06))
            .padding(.horizontal, PQSpacing.md)
        }
    }

    // MARK: - Empty State

    private var emptyView: some View {
        VStack(spacing: PQSpacing.md) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(Color.pqBlue.opacity(0.4))

            Text("No Transactions")
                .font(.pqTitle2)
                .foregroundStyle(Color.pqTextPrimary)

            Text("Your transaction history will appear here.")
                .font(.pqSubheadline)
                .foregroundStyle(Color.pqTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(PQSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Loading State

    private var firstPageLoadingView: some View {
        VStack(spacing: PQSpacing.md) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading transactions…")
                .font(.pqSubheadline)
                .foregroundStyle(Color.pqTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Error State

    private func errorView(message: String) -> some View {
        VStack(spacing: PQSpacing.lg) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(Color.pqRed.opacity(0.6))

            VStack(spacing: PQSpacing.sm) {
                Text("Something Went Wrong")
                    .font(.pqTitle2)
                    .foregroundStyle(Color.pqTextPrimary)

                Text(message)
                    .font(.pqSubheadline)
                    .foregroundStyle(Color.pqTextSecondary)
                    .multilineTextAlignment(.center)
            }

            PQButton(title: "Try Again") {
                viewModel.loadFirstPage()
            }
            .frame(maxWidth: 200)
        }
        .padding(PQSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.logoutTapped()
            } label: {
                Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                    .font(.pqSubheadline)
                    .foregroundStyle(Color.pqRed)
            }
        }
    }

    // MARK: - Helpers

    private func isLastTransaction(_ transaction: Transaction) -> Bool {
        viewModel.viewState.sections.last?.transactions.last?.id == transaction.id
    }
}

// MARK: - Preview

#Preview {
    let keychain = KeychainService()
    let session  = AppSession(keychain: keychain)
    let vm       = TransactionListViewModel(
        fetchTransactionsUseCase: MockFetchTransactionsUseCase(),
        appSession: session
    )
    return TransactionListView(viewModel: vm)
}

private class MockFetchTransactionsUseCase: FetchTransactionsUseCaseProtocol {
    func execute(page: Int) async throws -> PaginatedTransactions {
        PaginatedTransactions(
            transactions: [
                Transaction(
                    id: "1",
                    amountInCents: 5000,
                    currency: "USD",
                    type: .transfer,
                    status: .success,
                    createdAt: Date(),
                    destinationId: "wal_001"
                ),
                Transaction(
                    id: "2",
                    amountInCents: 10000,
                    currency: "USD",
                    type: .topUp,
                    status: .success,
                    createdAt: Date().addingTimeInterval(-86400),
                    destinationId: "wal_002"
                )
            ],
            currentPage: 1,
            totalPages: 2,
            totalItems: 10
        )
    }
}
