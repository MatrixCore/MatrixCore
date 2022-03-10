//
//  File.swift
//
//
//  Created by Finn Behrens on 10.03.22.
//

import Foundation
@testable import MatrixClient
import XCTest

@available(swift, introduced: 5.5)
final class ApiAuthInteractiveTests: XCTestCase {
    var flow = MatrixInteractiveAuth(flows: [
        MatrixInteractiveAuth.Flow(stages: [MatrixLoginFlow.recaptcha, MatrixLoginFlow.terms, MatrixLoginFlow.email]),
        MatrixInteractiveAuth
            .Flow(stages: [MatrixLoginFlow.recaptcha, MatrixLoginFlow.token, MatrixLoginFlow.oauth2,
                           MatrixLoginFlow.email]),
    ], params: [:], session: nil, completed: [MatrixLoginFlow.email, MatrixLoginFlow.terms], error: nil, errcode: nil)

    func testIsOptional() throws {
        XCTAssertTrue(flow.isOptional(.recaptcha))
        XCTAssertTrue(flow.isOptional(.terms))
        XCTAssertTrue(flow.isOptional(.email))
        XCTAssertTrue(flow.isOptional(.token))
        XCTAssertTrue(flow.isOptional(.oauth2))
        XCTAssertFalse(flow.isOptional(.msisdn))
    }

    func testIsRequired() throws {
        XCTAssertTrue(flow.isRequierd(.recaptcha))
        XCTAssertFalse(flow.isRequierd(.terms))
        XCTAssertFalse(flow.isRequierd(.token))
        XCTAssertFalse(flow.isRequierd(.oauth2))
        XCTAssertTrue(flow.isRequierd(.email))
        XCTAssertFalse(flow.isRequierd(.msisdn))
    }

    func testIsOptionalCompleted() throws {
        XCTAssertTrue(flow.isOptional(notCompletedFlow: .recaptcha))
        XCTAssertFalse(flow.isOptional(notCompletedFlow: .terms))
        XCTAssertFalse(flow.isOptional(notCompletedFlow: .email))
        XCTAssertTrue(flow.isOptional(notCompletedFlow: .token))
        XCTAssertTrue(flow.isOptional(notCompletedFlow: .oauth2))
        XCTAssertFalse(flow.isOptional(notCompletedFlow: .msisdn))
    }

    func testIsRequiredCompleted() throws {
        XCTAssertTrue(flow.isRequierd(notCompletedFlow: .recaptcha))
        XCTAssertFalse(flow.isRequierd(notCompletedFlow: .terms))
        XCTAssertFalse(flow.isRequierd(notCompletedFlow: .token))
        XCTAssertFalse(flow.isRequierd(notCompletedFlow: .oauth2))
        XCTAssertFalse(flow.isRequierd(notCompletedFlow: .email))
        XCTAssertFalse(flow.isRequierd(notCompletedFlow: .msisdn))
        XCTAssertTrue(flow.isRequierd(.email))
    }
}
