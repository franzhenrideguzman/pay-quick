//
//  KeychainService.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 3/30/26.
//

import Foundation
import Security

protocol KeychainServiceProtocol {
    func save(_ value: String, for key: KeychainService.Key) throws
    func load(_ key: KeychainService.Key) -> String?
    func delete(_ key: KeychainService.Key)
    func clearAll()
}

// MARK: - KeychainService
final class KeychainService: KeychainServiceProtocol {

    // MARK: Keys
    enum Key: String, CaseIterable {
        case accessToken  = "com.payquick.accessToken"
        case refreshToken = "com.payquick.refreshToken"
        case userId       = "com.payquick.userId"
        case userFullName = "com.payquick.userFullName"
        case userEmail    = "com.payquick.userEmail"
    }

    enum KeychainError: Error {
        case saveFailed(OSStatus)
        case encodingFailed
    }

    // MARK: - Write
    func save(_ value: String, for key: Key) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }

        delete(key)

        let query: [String: Any] = [
            kSecClass as String:          kSecClassGenericPassword,
            kSecAttrAccount as String:    key.rawValue,
            kSecValueData as String:      data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    // MARK: - Read
    func load(_ key: Key) -> String? {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String:  true,
            kSecMatchLimit as String:  kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }

    // MARK: - Delete
    func delete(_ key: Key) {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: - Clear All (Logout)
    func clearAll() {
        Key.allCases.forEach { delete($0) }
    }
}
