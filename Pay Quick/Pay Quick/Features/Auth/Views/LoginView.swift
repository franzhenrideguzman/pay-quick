//
//  LoginView.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 3/31/26.
//

import Foundation
import SwiftUI

struct LoginView: View {

    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                    .padding(.top, PQSpacing.xxl)
                    .padding(.bottom, PQSpacing.xl)

                formCard
                    .padding(.horizontal, PQSpacing.md)
            }
        }
        .background(Color.pqBgLight.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: PQSpacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: PQRadius.lg)
                    .fill(Color.pqBlue)
                    .frame(width: 72, height: 72)

                Text("PQ")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .shadow(color: Color.pqBlue.opacity(0.3), radius: 12, y: 6)

            Spacer().frame(height: PQSpacing.md)

            Text("PayQuick")
                .font(.pqTitle1)
                .foregroundStyle(Color.pqTextPrimary)

            Text("Sign in to your account")
                .font(.pqSubheadline)
                .foregroundStyle(Color.pqTextSecondary)
        }
    }

    // MARK: - Form Card

    private var formCard: some View {
        VStack(spacing: PQSpacing.lg) {
            VStack(spacing: PQSpacing.md) {
                PQTextField(
                    label: "Email",
                    placeholder: "smith@example.com",
                    text: $viewModel.viewState.email
                )
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)

                PQTextField(
                    label: "Password",
                    placeholder: "••••••••",
                    isSecure: true,
                    text: $viewModel.viewState.password
                )
                .textContentType(.password)
            }

            // Error message
            if let error = viewModel.viewState.errorMessage {
                errorBanner(message: error)
            }

            // Sign In button
            PQButton(
                title: "Sign In",
                isLoading: viewModel.viewState.isLoading
            ) {
                viewModel.loginTapped()
            }
            .disabled(!viewModel.viewState.canSubmit)
            .opacity(viewModel.viewState.canSubmit ? 1 : 0.55)

            devHint
        }
        .padding(PQSpacing.lg)
        .background(Color.pqSurface)
        .clipShape(RoundedRectangle(cornerRadius: PQRadius.xl))
        .shadow(color: .black.opacity(0.06), radius: 20, y: 4)
        .padding(.bottom, PQSpacing.xxl)
    }

    // MARK: - Error Banner

    private func errorBanner(message: String) -> some View {
        HStack(alignment: .top, spacing: PQSpacing.sm) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(Color.pqRed)

            Text(message)
                .font(.pqSubheadline)
                .foregroundStyle(Color.pqRed)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(PQSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.pqRed.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: PQRadius.sm))
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.spring(duration: 0.3), value: viewModel.viewState.errorMessage)
    }

    // MARK: - Dev Hint

    private var devHint: some View {
        VStack(spacing: PQSpacing.xs) {
            Divider()
            Text("Demo credentials")
                .font(.pqCaption)
                .foregroundStyle(Color.pqTextTertiary)
            Button {
                viewModel.viewState.email    = "smith@example.com"
                viewModel.viewState.password = "pass123"
            } label: {
                Text("smith@example.com  ·  pass123")
                    .font(.pqMono)
                    .foregroundStyle(Color.pqBlue)
            }
        }
        .padding(.top, PQSpacing.xs)
    }
}

// MARK: - Preview

#Preview {
    let keychain = KeychainService()
    let session  = AppSession(keychain: keychain)
    let vm       = LoginViewModel(
        authRepository: MockAuthRepository(),
        appSession: session
    )
    return LoginView(viewModel: vm)
}

// MARK: - Mock for Preview

private class MockAuthRepository: AuthRepositoryProtocol {
    func login(email: String, password: String) async throws -> (user: User, accessToken: String, refreshToken: String) {
        return (
            User(id: "1", fullName: "Paul Smith", email: "smith@example.com"),
            "mock_access_token",
            "mock_refresh_token"
        )
    }
}
