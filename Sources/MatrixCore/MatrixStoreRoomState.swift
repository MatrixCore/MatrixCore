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
