//
//  File.swift
//  File
//
//  Created by Finn Behrens on 27.09.21.
//

@testable import MatrixClient
import XCTest

final class MatrixClientTests: XCTestCase {
    let client = MatrixClient(homeserver: MatrixHomeserver(string: "https://matrix-client.matrix.org")!)

    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func testGetVersions() async throws {
        let version = try await client.getVersions()

        // Unlikely that the matrix.org homeserver will ever have less than 2 supported versions
        XCTAssertGreaterThanOrEqual(version.versions.count, 2)
    }

    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func testGetWellKnown() async throws {
        let client = MatrixClient(homeserver: MatrixHomeserver(string: "https://matrix.org")!)
        let wellKnown = try await client.getWellKnown()

        XCTAssertEqual(wellKnown.homeServerBaseUrl, "https://matrix-client.matrix.org")
        XCTAssertEqual(wellKnown.identityServerBaseUrl, "https://vector.im")
    }

    func testDecodeWellKnownExtraOptions() throws {
        let str = "{\"m.homeserver\": { \"base_url\": \"test\" }, \"dev.kloenk.client.test\": 1337 }"
        let data = Data(str.utf8)

        let decoder = JSONDecoder()
        let wellKnown = try decoder.decode(MatrixWellKnown.self, from: data)

        XCTAssertEqual(wellKnown.homeServerBaseUrl, "test")
        XCTAssertEqual(wellKnown.extraInfo["dev.kloenk.client.test"]?.value as? Int, 1337)
    }

    func testEncodeAndDecodeWellKnownExtraOptions() throws {
        let orig = MatrixWellKnown(
            homeserver: MatrixWellKnown.ServerInformation(baseURL: "test"),
            identityServer: nil,
            extraInfo: [
                "dev.kloenk.client.test": 1337,
                "dev.kloenk.client.test.str": "foobar",
            ]
        )

        let encoder = JSONEncoder()
        let encoded = try encoder.encode(orig)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(MatrixWellKnown.self, from: encoded)

        XCTAssertEqual(
            orig.extraInfo["dev.kloenk.client.test"]!.value as! Int,
            decoded.extraInfo["dev.kloenk.client.test"]!.value as! Int
        )
        XCTAssertEqual(
            orig.extraInfo["dev.kloenk.client.test.str"]!.value as! String,
            decoded.extraInfo["dev.kloenk.client.test.str"]!.value as! String
        )
        XCTAssertEqual(orig.homeServerBaseUrl, "test")
    }

    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func testGetLoginFlows() async throws {
        let flows = try await client.getLoginFlows()

        // Unlikely that the matrix.org homeserver will ever have less than 2 supported login flows
        XCTAssertGreaterThanOrEqual(flows.count, 2)
    }
}
