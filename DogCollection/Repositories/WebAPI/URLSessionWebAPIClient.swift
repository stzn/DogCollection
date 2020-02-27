//
//  APIClient.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

final class URLSessionWebAPIClient: WebAPIClient {
    private let session: URLSession
    init(session: URLSession) {
        self.session = session
    }

    func send(request: URLRequest) -> AnyPublisher<Response, WebAPIError> {
        session.dataTaskPublisher(for: request)
            .tryMap { (data, response) in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw WebAPIError.invalidResponse(response)
                }
                if let apiError = WebAPIError.error(from: httpResponse) {
                    throw apiError
                } else {
                    return Response(data: data, response: httpResponse)
                }
        }.mapError {
            .unknown($0)
        }.eraseToAnyPublisher()
    }
}

