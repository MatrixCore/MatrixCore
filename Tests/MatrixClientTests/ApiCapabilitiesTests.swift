//
//  File.swift
//
//
//  Created by Finn Behrens on 11.03.22.
//

import Foundation
@testable import MatrixClient
import XCTest

final class ApiCapabilityTests: XCTestCase {
    func testParsing() throws {
        let data = Data("""
        {
            "capabilities": {
                "com.example.custom.ratelimit": {
                    "max_requests_per_hour": 600
                },
                "m.change_password": {
                    "enabled": false
                },
                "m.room_versions": {
                    "available": {
                        "1": "stable",
                        "2": "stable",
                        "3": "unstable",
                        "test-version": "unstable"
                    },
                    "default": "1"
                }
            }
        }
        """.utf8)

        let capabilties = try MatrixCapabilities(fromMatrixRequestData: data)

        XCTAssertFalse(capabilties.canChangePassword)

        XCTAssertEqual(capabilties.defaultRoomVersion, "1")
        XCTAssertTrue(capabilties.roomVersions!.isVersionAvailable("1"))
        XCTAssertTrue(capabilties.roomVersions!.isVersionAvailable("2"))
        XCTAssertTrue(capabilties.roomVersions!.isVersionAvailable("3"))
        XCTAssertTrue(capabilties.roomVersions!.isVersionAvailable("test-version"))

        XCTAssertTrue(capabilties.roomVersions!.isVersionStable("1"))
        XCTAssertTrue(capabilties.roomVersions!.isVersionStable("2"))
        XCTAssertFalse(capabilties.roomVersions!.isVersionStable("3"))
        XCTAssertFalse(capabilties.roomVersions!.isVersionStable("test-version"))

        guard let ratelimitContainer = capabilties.capabilities.extraInfo["com.example.custom.ratelimit"]?
            .value as? [String: Any],
            let ratelimit = ratelimitContainer["max_requests_per_hour"] as? Int
        else {
            throw MatrixErrorCode.BadJSON
        }

        XCTAssertEqual(ratelimit, 600)
    }

    func testSet() throws {
        var capabilities = MatrixCapabilities()

        XCTAssertTrue(capabilities.canChangePassword)
        XCTAssertNil(capabilities.capabilities.changePassword)
        capabilities.canChangePassword = true
        XCTAssertTrue(capabilities.canChangePassword)
        XCTAssertNotNil(capabilities.capabilities.changePassword)
        capabilities.canChangePassword = false
        XCTAssertFalse(capabilities.canChangePassword)
        XCTAssertNotNil(capabilities.capabilities.changePassword)

        XCTAssertEqual(capabilities.defaultRoomVersion, "1")
    }
}
