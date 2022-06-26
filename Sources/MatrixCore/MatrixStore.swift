//
//  File.swift
//
//
//  Created by Finn Behrens on 25.03.22.
//

import Foundation
import MatrixClient
import OSLog

@available(swift, introduced: 5.5)
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public protocol MatrixStore {
    // MARK: - Account Info

    static var extraKeychainArguments: [String: Any] { get }
    
    /// Type for Account Informations.
    associatedtype AccountInfo: MatrixStoreAccountInfo
    //associatedtype RoomState: MatrixStoreRoomState
    //associatedtype AccountMapping: MatrixStoreAccountRoom

    func saveAccountInfo(account: AccountInfo) async throws
    func saveAccountInfo(_ mxID: MatrixFullUserIdentifier, name: String, homeServer: MatrixHomeserver, deviceId: String, accessToken: String?, saveToKeychain: Bool, extraKeychainArguments: [String: Any]) async throws -> AccountInfo

    func getAccountInfo(accountID: AccountInfo.AccountIdentifier) async throws -> AccountInfo

    func getAccountInfos() async throws -> [AccountInfo]

    func deleteAccountInfo(account: AccountInfo) async throws

    // MARK: - Room

    // MARK: Account Room Mapping
    /*func addAccountMapping(accountId: MatrixFullUserIdentifier, roomId: String) async throws
    func addAccountMapping(_ mapping: AccountMapping) async throws
    func getAccountMapping(accountId: MatrixFullUserIdentifier, roomId: String) async throws -> AccountMapping
    func getRoomsForAccount(accountI: MatrixFullUserIdentifier) async throws -> [AccountMapping]
    func getAccountsForRoom(roomId: MatrixFullUserIdentifier) async throws -> [AccountMapping]*/




    // MARK: Room State

    /*func addRoomState(state: RoomState) async throws

    func getRoomState(roomId: String) async throws -> [RoomState]
    func getRoomState(eventId: String) async throws -> RoomState?
    func getRoomState(roomId: String, stateType: String) async throws -> [RoomState]
    func getRoomState(roomId: String, stateKey: String) async throws -> [RoomState]
    func getRoomState(roomId: String, stateType: String, stateKey: String) async throws -> [RoomState]
     */
}
