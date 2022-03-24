//
//  File.swift
//
//
//  Created by Finn Behrens on 24.03.22.
//

import Foundation
@testable import MatrixClient
import XCTest

/// Test Canonical json as described in https://spec.matrix.org/v1.2/appendices/#canonical-json
final class CanonicalJsonTests: XCTestCase {
    func testEmptyJson() throws {
        let value = Value()

        let json = try MatrixClient.encode(value)

        XCTAssertEqual(json, Data("{}".utf8))

        struct Value: Encodable {}
    }

    func testOrderingJson() throws {
        let value = Value(two: "Two", one: 1)

        let json = try MatrixClient.encode(value)

        XCTAssertEqual(json, Data("{\"one\":1,\"two\":\"Two\"}".utf8))

        struct Value: Encodable {
            var two: String
            var one: Int
        }
    }

    func testUnicode() throws {
        let json = try MatrixClient.encode(Value(a: "日本語"))

        XCTAssertEqual(json, Data("{\"a\":\"日本語\"}".utf8))

        struct Value: Encodable {
            var a: String
        }
    }

    func testUnicodeKey() throws {
        let json = try MatrixClient.encode(Value(a: 2, b: 1))

        XCTAssertEqual(json, Data("{\"日\":1,\"本\":2}".utf8))

        struct Value: Encodable {
            var a: Int
            var b: Int

            enum CodingKeys: String, CodingKey {
                case a = "本"
                case b = "日"
            }
        }
    }
}
