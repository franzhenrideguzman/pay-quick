//
//  MockLoginUseCase.swift
//  Pay QuickTests
//
//  Created by Franz Henri De Guzman on 4/9/26.
//

import Foundation
@testable import Pay_Quick

final class MockLoginUseCase: LoginUseCaseProtocol {

    var shouldFail = false
    var errorToThrow: Error = NetworkError.serverError(statusCode: 401, message: "Unauthorized")
    var executeCallCount = 0

    var stubbedUser = User(
        id: "usr_001",
        fullName: "Paul Smith",
        email: "smith@example.com"
    )
    var stubbedAccessToken  = "mock_access_token"
    var stubbedRefreshToken = "mock_refresh_token"

    func execute(email: String, password: String) async throws -> (user: User, accessToken: String, refreshToken: String) {
        executeCallCount += 1
        if shouldFail { throw errorToThrow }
        return (stubbedUser, stubbedAccessToken, stubbedRefreshToken)
    }
}
