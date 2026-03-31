//
//  AuthRepositoryProtocol.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 3/30/26.
//

import Foundation

protocol AuthRepositoryProtocol {
    func login(email: String, password: String) async throws -> (user: User, accessToken: String, refreshToken: String)
}
