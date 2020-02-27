//
//  ImageAPI.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/25.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

final class ImageWebAPI: ImageDataLoader {
    private let client: WebAPIClient
    init(client: WebAPIClient) {
        self.client = client
    }

    func load(from url: URL) -> AnyPublisher<Data, Error> {
        client.send(request: URLRequest(url: url))
            .map { $0.data }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
