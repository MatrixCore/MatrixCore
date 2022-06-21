//
//  File.swift
//
//
//  Created by Finn Behrens on 24.04.22.
//

import Foundation
import MatrixClient

public protocol MatrixStoreRoomState {
    var eventId: String { get }
    var roomId: String { get }
    var stateKey: String { get }
    var sender: MatrixFullUserIdentifier? { get }
    var content: MatrixStateEventType { get }

    init(roomId: String, event: MatrixStateEvent) throws
}

public protocol MatrixStoreAccountRoom {
    var accountId: MatrixFullUserIdentifier { get }
    var roomId: MatrixFullUserIdentifier { get }
    var localMuted: Bool { get }

    init(accountId: MatrixFullUserIdentifier, roomId: String)
}

public extension MatrixStoreAccountRoom {
    var localMuted: Bool { true }
}

/*
@available(swift, introduced: 5.5)
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public extension MatrixStore {
    func addAccountMapping(accountId: MatrixFullUserIdentifier, roomId: String) async throws {
        let mapping = AccountMapping(accountId: accountId, roomId: roomId)
        try await self.addAccountMapping(mapping)
    }
}
*/
