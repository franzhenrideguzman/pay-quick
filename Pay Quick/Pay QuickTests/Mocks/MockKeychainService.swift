//
//  MockKeychainService.swift
//  Pay QuickTests
//
//  Created by Franz Henri De Guzman on 4/1/26.
//

import Foundation
@testable import Pay_Quick

final class MockKeychainService: KeychainServiceProtocol {

    // In-memory storage — simulates Keychain without touching the real one
    private var storage: [KeychainService.Key: String] = [:]

    nonisolated func save(_ value: String, for key: KeychainService.Key) throws {
        storage[key] = value
    }

    nonisolated func load(_ key: KeychainService.Key) -> String? {
        storage[key]
    }

    nonisolated func delete(_ key: KeychainService.Key) {
        storage.removeValue(forKey: key)
    }

    nonisolated func clearAll() {
        storage.removeAll()
    }

    // MARK: - Test Helpers

    var isEmpty: Bool {
        storage.isEmpty
    }

    func has(_ key: KeychainService.Key) -> Bool {
        storage[key] != nil
    }
}
