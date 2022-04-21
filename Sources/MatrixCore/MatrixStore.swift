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
    func getAccountInfo(accountID: AccountInfo.AccountIdentifier) async throws -> AccountInfo

    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func getAccountInfos() async throws -> [AccountInfo]

    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func deleteAccountInfo(account: AccountInfo) async throws
}
