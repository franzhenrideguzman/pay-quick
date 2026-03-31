//
//  LoginViewModel.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 3/31/26.
//

import Foundation
import Combine

// MARK: - LoginViewState

struct LoginViewState {
    var email: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil

    var canSubmit: Bool {
        !email.isEmpty && !password.isEmpty && !isLoading
    }
}

// MARK: - LoginViewModel

@MainActor
final class LoginViewModel: ObservableObject {

    // MARK: - Published State
    @Published var viewState = LoginViewState()

    // MARK: - Dependencies
    private let authRepository: AuthRepositoryProtocol
    private let appSession: AppSession

    // MARK: - Init
    init(authRepository: AuthRepositoryProtocol, appSession: AppSession) {
        self.authRepository = authRepository
        self.appSession = appSession
    }

    // MARK: - Intent

    func loginTapped() {
        guard viewState.canSubmit else { return }

        viewState.isLoading = true
        viewState.errorMessage = nil

        Task {
            do {
                let (user, accessToken, refreshToken) = try await authRepository.login(
                    email: viewState.email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: viewState.password
                )
                appSession.signIn(
                    user: user,
                    accessToken: accessToken,
                    refreshToken: refreshToken
                )
            } catch {
                viewState.errorMessage = friendlyMessage(for: error)
            }
            viewState.isLoading = false
        }
    }

    // MARK: - Private

    private func friendlyMessage(for error: Error) -> String {
        (error as? NetworkError)?.errorDescription ?? error.localizedDescription
    }
}
