//
//  ContentTests.swift
//  
//
//  Created by Finn Behrens on 22.06.22.
//

import XCTest
@testable import MatrixClient

final class ContentURITests: XCTestCase {

    func testGetComponents() throws {
        let uri = MatrixContentURL(string: "mxc://example.com/id")
    }
}
