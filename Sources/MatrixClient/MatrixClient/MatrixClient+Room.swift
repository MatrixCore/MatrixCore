//
//  File.swift
//
//
//  Created by Finn Behrens on 25.03.22.
//

import Foundation

public extension MatrixClient {
    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func sendEvent(_ event: MatrixEvent, room: String, txid: Int) async throws -> MatrixRoomSendEvent {
        try await MatrixRoomSendEventRequest(body: event, roomID: room)
            .response(on: homeserver, withToken: accessToken, with: txid)
    }

    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func sendEvent(text: String, room: String, txid: Int) async throws -> MatrixRoomSendEvent {
        try await MatrixRoomSendEventRequest(
            body: MatrixMessageEvent(content: MatrixMessageText(body: text)),
            roomID: room
        )
        .response(on: homeserver, withToken: accessToken, with: txid)
    }
}
