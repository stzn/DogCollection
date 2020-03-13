//
//  MockedHTTPClient.swift
//  DogCollectionTests
//
//  Created by Shinzan Takata on 2020/03/13.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation
@testable import DogCollection

final class MockedHTTPClient: Mock, HTTPClient {
    enum Action: Equatable {
        case load
    }

    var actions = MockActions<Action>(expected: [])

    var response: Response?

    func send(request: URLRequest) -> AnyPublisher<Response, HTTPClientError> {
        actions.factual.append(.load)
        guard let response = response else {
            return Fail(error: HTTPClientError.unknown(MockError.valueNotSet)).eraseToAnyPublisher()
        }
        return Just(response).setFailureType(to: HTTPClientError.self).eraseToAnyPublisher()
    }
}
