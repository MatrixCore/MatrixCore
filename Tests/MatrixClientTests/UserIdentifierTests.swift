//
//  File.swift
//
//
//  Created by Finn Behrens on 24.03.22.
//

import Foundation
@testable import MatrixClient
import XCTest

final class UserIdentifierTests: XCTestCase {
    func testFromRawValue() {
        var userIdentifier = MatrixUserIdentifier(rawValue: "@localpart:example.com")

        XCTAssertNotNil(userIdentifier)

        userIdentifier = MatrixUserIdentifier(rawValue: "@$this\\is-not!allowed:example.com")

        XCTAssertNil(userIdentifier)
    }

    func testFormat() {
        var userIdentifier = MatrixUserIdentifier(rawValue: "@localpart:example.com")!

        XCTAssertEqual(userIdentifier.FQMXID, userIdentifier.rawValue)
        XCTAssertEqual(userIdentifier.FQMXID, "@localpart:example.com")

        userIdentifier = MatrixUserIdentifier(rawValue: "localpart")!

        XCTAssertEqual(userIdentifier.rawValue, "localpart")
        XCTAssertNil(userIdentifier.FQMXID)
    }
    
    func testFullId() {
        let userIdentifier = MatrixFullUserIdentifier(string: "@localpart:example.com")!
        
        XCTAssertEqual(userIdentifier.localpart, "localpart")
        XCTAssertEqual(userIdentifier.domain, "example.com")
        XCTAssertEqual(userIdentifier.FQMXID, "@localpart:example.com")
    }
}
