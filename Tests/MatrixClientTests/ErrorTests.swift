//
//  ErrorTests.swift
//
//
//  Created by Finn Behrens on 24.04.22.
//

@testable import MatrixClient
import XCTest

class ErrorTests: XCTestCase {
    func testDoesNotContain() throws {
        XCTAssertFalse(MatrixServerError.KnownCodingKeys.doesNotContain(.init(stringValue: "error")!))
        XCTAssertFalse(MatrixServerError.KnownCodingKeys.doesNotContain(.init(stringValue: "flows")!))
    }

    func testExample() throws {
        let data = Data("""
        {
        "session": "session_id",
        "flows": [
        {
        "stages": [
        "m.login.recaptcha",
        "m.login.terms",
        "m.login.email.identity"
        ]
        }
        ],
        "params": {
        "m.login.recaptcha": {
        "public_key": "recaptha_public_key"
        },
        "m.login.terms": {
        "policies": {
        "privacy_policy": {
          "version": "1.0",
          "en": {
            "name": "Terms and Conditions",
            "url": "https://example.com/_matrix/consent?v=1.0"
          }
        }
        }
        }
        }
        }
        """.utf8)

        let error = try MatrixServerError(json: data, code: 401)

        XCTAssertNotNil(error.interactiveAuth)
        XCTAssertEqual(error.interactiveAuth?.session, "session_id")
        XCTAssertEqual(error.interactiveAuth?.flows.count, 1)
    }
}
