//
//  AppContainer.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 3/31/26.
//

import Foundation

@MainActor
final class AppContainer {

    // MARK: - Shared
    let keychain: KeychainServiceProtocol
    let apiClient: APIClientProtocol
    let appSession: AppSession

    // MARK: - Init
    init() {
        let keychain = KeychainService()
        self.keychain = keychain

        let appSession = AppSession(keychain: keychain)
        self.appSession = appSession

        let interceptor = TokenRefreshInterceptor(
            keychain: keychain,
            onSessionExpired: {
                Task { @MainActor in
                    appSession.invalidate()
                }
            }
        )

        self.apiClient = APIClient(refreshInterceptor: interceptor)
    }

    // MARK: - Factory Methods

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(
            authRepository: AuthRepository(
                apiClient: apiClient,
                keychain: keychain
            ),
            appSession: appSession
        )
    }

    func makeTransactionListViewModel() -> TransactionListViewModel {
        TransactionListViewModel(
            transactionRepository: TransactionRepository(
                apiClient: apiClient,
                keychain: keychain
            ),
            appSession: appSession
        )
    }
}
