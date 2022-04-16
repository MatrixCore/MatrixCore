//
//  File.swift
//
//
//  Created by Finn Behrens on 25.03.22.
//

import Foundation
import MatrixClient
import OSLog

public protocol MatrixStore {
    // MARK: - Account Info

    /// Type for Account Informations.
    associatedtype AccountInfo: MatrixStoreAccountInfo

    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func saveAccountInfo(account: AccountInfo) async throws

    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func getAccountInfo(accountID: MatrixUserIdentifier) async throws -> AccountInfo

    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func getAccountInfos() async throws -> [AccountInfo]
}

public protocol MatrixStoreAccountInfo {
    var name: String { get }
    var displayName: String? { get }
    var mxID: MatrixUserIdentifier { get }
    var homeServer: MatrixHomeserver { get }
    var accessToken: String? { get }
}

// TODO: only on Darwin platforms
public extension MatrixStoreAccountInfo {
    /// Load the ``accessToken`` from Keychain.
    static func getFromKeychain(account: MatrixUserIdentifier,
                                extraKeychainArguments: [String: Any] = [:]) throws -> String
    {
        guard let userID = account.FQMXID,
              let domain = account.domain
        else {
            throw MatrixError.NotFound
        }

        var keychainQuery = extraKeychainArguments
        keychainQuery[kSecClass as String] = kSecClassInternetPassword
        keychainQuery[kSecMatchLimit as String] = kSecMatchLimitOne
        keychainQuery[kSecAttrAccount as String] = userID
        keychainQuery[kSecAttrServer as String] = domain
        keychainQuery[kSecReturnAttributes as String] = true
        keychainQuery[kSecReturnData as String] = true

        var item: CFTypeRef?
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &item)
        guard status == errSecSuccess else {
            throw MatrixCoreError.keychainError(status)
        }

        guard let existingItem = item as? [String: Any],
              let tokenData = existingItem[kSecValueData as String] as? Data,
              let token = String(data: tokenData, encoding: .utf8)
        else {
            throw MatrixCoreError.keychainError(errSecInvalidData)
        }

        return token
    }

    /// Save the ``accessToken`` to keychain, using the accountID data as identifier.
    func saveToKeychain(extraKeychainArguments: [String: Any] = [:]) throws {
        guard let userID = mxID.FQMXID,
              let domain = mxID.domain,
              let accessToken = self.accessToken?.data(using: .utf8)
        else {
            throw MatrixError.NotFound
        }

        var keychainInsertQuery = extraKeychainArguments
        keychainInsertQuery[kSecClass as String] = kSecClassInternetPassword
        keychainInsertQuery[kSecAttrAccount as String] = userID
        keychainInsertQuery[kSecAttrServer as String] = domain
        keychainInsertQuery[kSecValueData as String] = accessToken

        let status = SecItemAdd(keychainInsertQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw MatrixCoreError.keychainError(status)
        }
    }

    func deleteFromKeychain(extraKeychainArguments: [String: Any] = [:]) throws {
        guard let userID = mxID.FQMXID,
              let domain = mxID.domain
        else {
            throw MatrixError.NotFound
        }

        var keychainQuery = extraKeychainArguments
        keychainQuery[kSecClass as String] = kSecClassInternetPassword
        keychainQuery[kSecAttrAccount as String] = userID
        keychainQuery[kSecAttrServer as String] = domain

        let status = SecItemDelete(keychainQuery as CFDictionary)
        guard status == errSecSuccess else {
            throw MatrixCoreError.keychainError(status)
        }
    }
}
