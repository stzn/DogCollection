//
//  APIClient.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

struct URLSessionAPIClient: APIClient {
    private let session: URLSession
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    func send(request: URLRequest) -> AnyPublisher<Response, APIError> {
        session.dataTaskPublisher(for: request)
            .tryMap { (data, response) in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse(response)
                }
                if let apiError = APIError.error(from: httpResponse) {
                    throw apiError
                } else {
                    return Response(data: data, response: httpResponse)
//                    do {
//                        let model = try M.decoder.decode(M.self, from: data)
//                        return Response(model: model, response: httpResponse)
//                    } catch let error as DecodingError {
//                        throw APIError.decodingError(error)
//                    }
                }
        }.mapError {
            .unknown($0)
        }.eraseToAnyPublisher()
    }
}

