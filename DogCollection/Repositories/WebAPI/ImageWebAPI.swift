//
//  ImageAPI.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/25.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

protocol ImageDataDownloadable {
    func download(from url: URL) -> AnyPublisher<Data, Error>
}

final class ImageWebAPI: ImageDataDownloadable, ObservableObject {
    private let client: WebAPIClient
    init(client: WebAPIClient) {
        self.client = client
    }

    func download(from url: URL) -> AnyPublisher<Data, Error> {
        client.send(request: URLRequest(url: url))
            .map { $0.data }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
