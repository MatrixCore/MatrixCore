//
//  Interactive.swift
//
//
//  Created by Finn Behrens on 09.03.22.
//

import AnyCodable
import Foundation

public struct MatrixInteractiveAuth: MatrixResponse {
    public var flows: [Flow]

    /// This section contains any information that the client will need to know in order to use a given type of authentication.
    /// For each authentication type presented, that type may be present as a key in this dictionary.
    /// For example, the public part of an OAuth client ID could be given here.
    public var params: [String: AnyCodable]

    /// This is a session identifier that the client must pass back to the homeserver, if one is provided,
    /// in subsequent attempts to authenticate in the same API call.
    public var session: String?

    public var completed: [String]?

    public var notCompletedStages: [Flow] {
        var ret: [Flow] = []
        for flow in flows {
            var stages: [String] = []
            for stage in flow.stages {
                if !(completed?.contains(stage) ?? false) {
                    stages.append(stage)
                }
            }
            ret.append(.init(stages: stages))
        }
        return ret
    }

    public var nextStage: String? {
        notCompletedStages[0].stages[0]
    }

    public var nextStageWithParams: (String, AnyCodable?)? {
        guard let nextStage = nextStage else {
            return nil
        }

        let params = params[nextStage]
        return (nextStage, params)
    }
}

public extension MatrixInteractiveAuth {
    struct Flow: Codable {
        public var stages: [String] = []
    }
}
