//
//  File.swift
//
//
//  Created by Finn Behrens on 26.04.22.
//

import Foundation
import MatrixClient
/*
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public extension MatrixCore {
    /// Start a task to sync
    ///
    /// - Throws: ``MatrixCoreError`` if sync is already running
    func startSync() throws {
        guard syncTask == nil else {
            throw MatrixCoreError.syncAlreadyStarted
        }

        syncTask = buildSyncTask()
    }

    private nonisolated func buildSyncTask() -> Task<Void, Never> {
        Task(priority: .background) { [self] in
            var parameters = MatrixSyncRequest.Parameters(timeout: 45 * 1000)
            while true {
                do {
                    parameters = try await self.runSync(parameters: parameters)

                    parameters.presence = await self.presence

                    try Task.checkCancellation()
                } catch is CancellationError {
                    return
                } catch {
                    MatrixCoreLogger.logger.fault("Sync task: \(error.localizedDescription)")
                }
            }
        }
    }

    nonisolated func runSync(parameters: MatrixSyncRequest.Parameters) async throws -> MatrixSyncRequest.Parameters {
        var parameters = parameters
        let client = await self.client
        let sync = try await client.sync(parameters: parameters)

        try await parseSync(sync)

        parameters.since = sync.nextBatch
        return parameters
    }

    nonisolated func parseSync(_ sync: MatrixSync) async throws {
        guard let rooms = sync.rooms else {
            return
        }

        var acountRooms: [String] = []

        guard let joinedRooms = rooms.joined else {
            return
        }

        for (roomId, room) in joinedRooms {
            try await parseRoom(roomId: roomId, room: room)
            acountRooms.append(roomId)
        }

        // TODO: save account <-> roomId mapping
    }

    nonisolated func parseRoom(roomId: String, room: MatrixSync.JoinedRoom) async throws {
        MatrixCoreLogger.logger.trace("Parsing room \(roomId)")

        if let timeline = room.timeline {
            for event in timeline.events ?? [] {
                if let event = event as? MatrixStateEvent {
                    try await store.addRoomState(state: .init(roomId: roomId, event: event))
                }
            }
        }
    }

    /// Stop the sync task
    ///
    /// - Throws: ``MatrixCoreError`` if the sync task is not running
    func stopSync() throws {
        guard let syncTask = self.syncTask,
              !syncTask.isCancelled
        else {
            throw MatrixCoreError.syncNotRunning
        }
        syncTask.cancel()
        self.syncTask = nil
    }
}*/
