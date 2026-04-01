//
//  LoginResponse.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 3/31/26.
//

import Foundation

struct LoginResponse: Decodable {
    struct Data: Decodable {
        struct UserResponse: Decodable {
            let user_id: String
            let full_name: String
            let email: String
        }
        let access_token: String
        let expires_in: Int
        let refresh_token: String
        let token_type: String
        let user: UserResponse
    }
    let status: String
    let message: String
    let data: Data
}

// MARK: - Mapping to Domain
extension LoginResponse {
    func toDomain() -> (user: User, accessToken: String, refreshToken: String) {
        let user = User(
            id: data.user.user_id,
            fullName: data.user.full_name,
            email: data.user.email
        )
        return (user, data.access_token, data.refresh_token)
    }
}
