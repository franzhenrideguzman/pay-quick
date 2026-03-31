//
//  AppSession.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 3/30/26.
//

import Foundation
import Combine

@MainActor
final class AppSession: ObservableObject {

    // MARK: - Published State
    @Published private(set) var isAuthenticated: Bool = false
    @Published private(set) var currentUser: User?

    // MARK: - Dependencies
    private let keychain: KeychainServiceProtocol

    // MARK: - Init
    init(keychain: KeychainServiceProtocol) {
        self.keychain = keychain
        restoreSession()
    }

    // MARK: - Public

    func signIn(user: User, accessToken: String, refreshToken: String) {
        try? keychain.save(accessToken,   for: .accessToken)
        try? keychain.save(refreshToken,  for: .refreshToken)
        try? keychain.save(user.id,       for: .userId)
        try? keychain.save(user.fullName, for: .userFullName)
        try? keychain.save(user.email,    for: .userEmail)

        currentUser = user
        isAuthenticated = true
    }

    func signOut() {
        keychain.clearAll()
        currentUser = nil
        isAuthenticated = false
    }

    /// Called by TokenRefreshInterceptor when refresh token is invalid
    func invalidate() {
        signOut()
    }

    // MARK: - Private

    private func restoreSession() {
        guard
            let accessToken = keychain.load(.accessToken),
            let userId      = keychain.load(.userId),
            let fullName    = keychain.load(.userFullName),
            let email       = keychain.load(.userEmail),
            !accessToken.isEmpty
        else { return }

        currentUser = User(id: userId, fullName: fullName, email: email)
        isAuthenticated = true
    }
}
