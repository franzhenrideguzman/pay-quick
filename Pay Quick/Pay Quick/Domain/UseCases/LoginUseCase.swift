//
//  LoginUseCase.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 4/8/26.
//

import Foundation

protocol LoginUseCaseProtocol {
    func execute(email: String, password: String) async throws -> (user: User, accessToken: String, refreshToken: String)
}

final class LoginUseCase: LoginUseCaseProtocol {

    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func execute(email: String, password: String) async throws -> (user: User, accessToken: String, refreshToken: String) {
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty else {
            throw ValidationError.emptyEmail
        }

        guard trimmedEmail.contains("@") else {
            throw ValidationError.invalidEmail
        }

        guard !password.isEmpty else {
            throw ValidationError.emptyPassword
        }

        return try await authRepository.login(email: trimmedEmail, password: password)
    }
}

// MARK: - ValidationError

enum ValidationError: Error, LocalizedError {
    case emptyEmail
    case invalidEmail
    case emptyPassword

    var errorDescription: String? {
        switch self {
        case .emptyEmail:    return "Email cannot be empty."
        case .invalidEmail:  return "Please enter a valid email address."
        case .emptyPassword: return "Password cannot be empty."
        }
    }
}

