//
//  APIClient.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    init(session: URLSession) {
        self.session = session
    }

    func send(request: URLRequest) -> AnyPublisher<Response, HTTPClientError> {
        session.dataTaskPublisher(for: request)
            .tryMap { (data, response) in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw HTTPClientError.invalidResponse(response)
                }
                if let apiError = HTTPClientError.error(from: httpResponse) {
                    throw apiError
                } else {
                    return Response(data: data, response: httpResponse)
                }
        }.mapError {
            if let error = $0 as? HTTPClientError {
                return error
            }
            return .unknown($0)
        }.eraseToAnyPublisher()
    }
}

