//
//  File.swift
//
//
//  Created by Finn Behrens on 10.03.22.
//

import Foundation
@testable import MatrixClient
import XCTest

final class ApiAuthInteractiveTests: XCTestCase {
    var flow = MatrixInteractiveAuth(flows: [
        MatrixInteractiveAuth.Flow(stages: [MatrixLoginFlowType.recaptcha, MatrixLoginFlowType.terms, MatrixLoginFlowType.email]),
        MatrixInteractiveAuth
            .Flow(stages: [MatrixLoginFlowType.recaptcha, MatrixLoginFlowType.token, MatrixLoginFlowType.oauth2,
                           MatrixLoginFlowType.email]),
    ], params: [:], session: nil, completed: [MatrixLoginFlowType.email, MatrixLoginFlowType.terms])

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
