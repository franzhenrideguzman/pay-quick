//
//  LoginViewModelTests.swift
//  Pay QuickTests
//
//  Created by Franz Henri De Guzman on 4/1/26.
//

import Testing
import XCTest
@testable import Pay_Quick

@MainActor
final class LoginViewModelTests: XCTestCase {

    var sut: LoginViewModel!
    var mockUseCase: MockLoginUseCase!
    var mockKeychain: MockKeychainService!
    var appSession: AppSession!

    override func setUp() {
        super.setUp()
        mockUseCase  = MockLoginUseCase()
        mockKeychain = MockKeychainService()
        appSession   = AppSession(keychain: mockKeychain)
        sut          = LoginViewModel(loginUseCase: mockUseCase, appSession: appSession)
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
        XCTAssertEqual(sut.viewState.email, "")
        XCTAssertEqual(sut.viewState.password, "")
        XCTAssertFalse(sut.viewState.isLoading)
        XCTAssertNil(sut.viewState.errorMessage)
    }

    func test_canSubmit_isFalse_whenFieldsAreEmpty() {
        sut.viewState.email    = ""
        sut.viewState.password = ""
        XCTAssertFalse(sut.viewState.canSubmit)
    }

    func test_canSubmit_isFalse_whenEmailIsEmpty() {
        sut.viewState.email    = ""
        sut.viewState.password = "pass123"
        XCTAssertFalse(sut.viewState.canSubmit)
    }

    func test_canSubmit_isFalse_whenPasswordIsEmpty() {
        sut.viewState.email    = "smith@example.com"
        sut.viewState.password = ""
        XCTAssertFalse(sut.viewState.canSubmit)
    }

    func test_canSubmit_isTrue_whenBothFieldsFilled() {
        sut.viewState.email    = "smith@example.com"
        sut.viewState.password = "pass123"
        XCTAssertTrue(sut.viewState.canSubmit)
    }

    // MARK: - Login Success

    func test_loginTapped_success_setsAuthenticated() async throws {
        sut.viewState.email    = "smith@example.com"
        sut.viewState.password = "pass123"

        sut.loginTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(appSession.isAuthenticated)
        XCTAssertEqual(appSession.currentUser?.email, "smith@example.com")
        XCTAssertFalse(sut.viewState.isLoading)
        XCTAssertNil(sut.viewState.errorMessage)
    }

    func test_loginTapped_success_savesTokensToKeychain() async throws {
        sut.viewState.email    = "smith@example.com"
        sut.viewState.password = "pass123"

        sut.loginTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockKeychain.has(.accessToken))
        XCTAssertTrue(mockKeychain.has(.refreshToken))
        XCTAssertEqual(mockKeychain.load(.accessToken), "mock_access_token")
    }

    func test_loginTapped_callsUseCase_once() async throws {
        sut.viewState.email    = "smith@example.com"
        sut.viewState.password = "pass123"

        sut.loginTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(mockUseCase.executeCallCount, 1)
    }

    // MARK: - Login Failure

    func test_loginTapped_failure_setsErrorMessage() async throws {
        mockUseCase.shouldFail   = true
        mockUseCase.errorToThrow = NetworkError.serverError(statusCode: 401, message: "Invalid credentials")

        sut.viewState.email    = "wrong@example.com"
        sut.viewState.password = "wrongpass"

        sut.loginTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertFalse(appSession.isAuthenticated)
        XCTAssertNotNil(sut.viewState.errorMessage)
        XCTAssertFalse(sut.viewState.isLoading)
    }

    func test_loginTapped_failure_doesNotSaveTokens() async throws {
        mockUseCase.shouldFail = true

        sut.viewState.email    = "wrong@example.com"
        sut.viewState.password = "wrongpass"

        sut.loginTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertFalse(mockKeychain.has(.accessToken))
        XCTAssertFalse(mockKeychain.has(.refreshToken))
    }

    func test_loginTapped_noInternet_setsErrorMessage() async throws {
        mockUseCase.shouldFail   = true
        mockUseCase.errorToThrow = NetworkError.noInternetConnection

        sut.viewState.email    = "smith@example.com"
        sut.viewState.password = "pass123"

        sut.loginTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(
            sut.viewState.errorMessage,
            "No internet connection. Please check your network."
        )
    }

    // MARK: - Guard

    func test_loginTapped_doesNothing_whenCanSubmitIsFalse() async throws {
        sut.viewState.email    = ""
        sut.viewState.password = ""

        sut.loginTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(mockUseCase.executeCallCount, 0)
    }
}
