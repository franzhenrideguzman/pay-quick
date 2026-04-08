//
//  TransactionListViewModelTests.swift
//  Pay QuickTests
//
//  Created by Franz Henri De Guzman on 4/1/26.
//

import Testing
import XCTest
@testable import Pay_Quick

@MainActor
final class TransactionListViewModelTests: XCTestCase {

    var sut: TransactionListViewModel!
    var mockUseCase: MockFetchTransactionsUseCase!
    var mockKeychain: MockKeychainService!
    var appSession: AppSession!

    override func setUp() {
        super.setUp()
        mockUseCase  = MockFetchTransactionsUseCase()
        mockKeychain = MockKeychainService()
        appSession   = AppSession(keychain: mockKeychain)
        sut          = TransactionListViewModel(
            fetchTransactionsUseCase: mockUseCase,
            appSession: appSession
        )
    }

    override func tearDown() {
        sut          = nil
        mockUseCase  = nil
        mockKeychain = nil
        appSession   = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func test_initialState_isEmpty() {
        XCTAssertTrue(sut.viewState.sections.isEmpty)
        XCTAssertFalse(sut.viewState.isLoadingFirstPage)
        XCTAssertFalse(sut.viewState.isLoadingNextPage)
        XCTAssertNil(sut.viewState.errorMessage)
    }

    // MARK: - Load First Page

    func test_onAppear_loadsFirstPage() async throws {
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(mockUseCase.executeCallCount, 1)
        XCTAssertFalse(sut.viewState.sections.isEmpty)
    }

    func test_onAppear_calledTwice_onlyFetchesOnce() async throws {
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(mockUseCase.executeCallCount, 1)
    }

    func test_loadFirstPage_setsCorrectPageState() async throws {
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(sut.viewState.currentPage, 1)
        XCTAssertEqual(sut.viewState.totalPages, 2)
        XCTAssertTrue(sut.viewState.hasNextPage)
    }

    // MARK: - Month Grouping

    func test_transactions_areGroupedByMonth() async throws {
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(sut.viewState.sections.count, 2)
    }

    func test_sections_areOrderedNewestFirst() async throws {
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        let firstSectionTitle  = sut.viewState.sections.first?.title ?? ""
        let secondSectionTitle = sut.viewState.sections.last?.title ?? ""

        XCTAssertTrue(firstSectionTitle.contains("2025"))
        XCTAssertNotEqual(firstSectionTitle, secondSectionTitle)
    }

    func test_transactionsWithinSection_areOrderedNewestFirst() async throws {
        mockUseCase.stubbedPages[1] = PaginatedTransactions(
            transactions: [
                Transaction(id: "a", amountInCents: 1000, currency: "USD", type: .transfer,
                           status: .success, createdAt: Date.make(year: 2025, month: 10, day: 1),
                           destinationId: "wal_a"),
                Transaction(id: "b", amountInCents: 2000, currency: "USD", type: .topUp,
                           status: .success, createdAt: Date.make(year: 2025, month: 10, day: 9),
                           destinationId: "wal_b"),
            ],
            currentPage: 1, totalPages: 1, totalItems: 2
        )

        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        let firstTransaction = sut.viewState.sections.first?.transactions.first
        XCTAssertEqual(firstTransaction?.id, "b")
    }

    // MARK: - Pagination

    func test_onLastRowAppeared_loadsNextPage() async throws {
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        sut.onLastRowAppeared()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(mockUseCase.executeCallCount, 2)
        XCTAssertEqual(sut.viewState.currentPage, 2)
    }

    func test_onLastRowAppeared_appendsTransactions() async throws {
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        let sectionsAfterPage1 = sut.viewState.sections.count

        sut.onLastRowAppeared()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertGreaterThan(sut.viewState.sections.count, sectionsAfterPage1)
    }

    func test_onLastRowAppeared_doesNotLoad_whenNoNextPage() async throws {
        mockUseCase.stubbedPages[1] = PaginatedTransactions(
            transactions: [
                Transaction(id: "1", amountInCents: 5000, currency: "USD", type: .transfer,
                           status: .success, createdAt: Date.october2025, destinationId: "wal_001")
            ],
            currentPage: 1, totalPages: 1, totalItems: 1
        )

        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        sut.onLastRowAppeared()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(mockUseCase.executeCallCount, 1)
    }

    // MARK: - Error Handling

    func test_loadFirstPage_failure_setsErrorMessage() async throws {
        mockUseCase.shouldFail   = true
        mockUseCase.errorToThrow = NetworkError.noInternetConnection

        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertNotNil(sut.viewState.errorMessage)
        XCTAssertTrue(sut.viewState.sections.isEmpty)
        XCTAssertFalse(sut.viewState.isLoadingFirstPage)
    }

    func test_loadFirstPage_failure_setsCorrectErrorMessage() async throws {
        mockUseCase.shouldFail   = true
        mockUseCase.errorToThrow = NetworkError.noInternetConnection

        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(
            sut.viewState.errorMessage,
            "No internet connection. Please check your network."
        )
    }

    // MARK: - Logout

    func test_logoutTapped_clearsSession() {
        try? mockKeychain.save("token", for: .accessToken)
        appSession.signIn(
            user: User(id: "1", fullName: "Paul", email: "smith@example.com"),
            accessToken: "token",
            refreshToken: "refresh"
        )

        sut.logoutTapped()

        XCTAssertFalse(appSession.isAuthenticated)
        XCTAssertNil(appSession.currentUser)
        XCTAssertTrue(mockKeychain.isEmpty)
    }
}
