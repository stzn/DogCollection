//
//  MockedWebAPIs.swift
//  DogCollectionTests
//
//  Created by Shinzan Takata on 2020/02/28.
//  Copyright © 2020 shiz. All rights reserved.
//

import XCTest
import Combine
@testable import DogCollection

final class MockHTTPClient: HTTPClient, Mock {
    enum Action: Equatable {
        case send
    }
    var actions = MockActions<Action>(expected: [])

    var publisher: AnyPublisher<Response, HTTPClientError>!
    private init(publisher: AnyPublisher<Response, HTTPClientError>) {
        self.publisher = publisher
    }

    static func output(response: Response) -> MockHTTPClient {
        let publisher = Just(response).setFailureType(to: HTTPClientError.self).eraseToAnyPublisher()
        return Self(publisher: publisher)
    }

    static func failure(error: HTTPClientError) -> MockHTTPClient {
        let publisher = Fail<Response, HTTPClientError>(error: error).eraseToAnyPublisher()
        return Self(publisher: publisher)
    }

    func send(request: URLRequest) -> AnyPublisher<Response, HTTPClientError> {
        actions.factual.append(.send)
        return publisher
    }
}

class TestWebAPI: WebAPI {
    var client: HTTPClient = MockHTTPClient.output(response: Response(data: Data(), response: okResponse))
    let baseURL: URL = testURL
    let queue = DispatchQueue(label: "test")
}

final class MockedBreedListLoader: TestWebAPI, Mock, BreedListLoader {
    enum Action: Equatable {
        case loadBreedList
    }
    var actions = MockActions<Action>(expected: [])

    var breedListResponse: Result<[Breed], Error> = .failure(MockError.valueNotSet)

    func load() -> AnyPublisher<[Breed], Error> {
        register(.loadBreedList)
        return breedListResponse.publish()
    }
}

final class MockedDogImageListLoader: TestWebAPI, Mock, DogImageListLoader {
    enum Action: Equatable {
        case loadDogImageList
    }
    var actions = MockActions<Action>(expected: [])

    var dogImageListResponse: Result<[DogImage], Error> = .failure(MockError.valueNotSet)

    func load(of breed: BreedType) -> AnyPublisher<[DogImage], Error> {
        register(.loadDogImageList)
        return dogImageListResponse.publish()
    }
}

final class MockedImageDataLoader: Mock, ImageDataLoader {
    enum Action: Equatable {
        case loadImage(URL)
    }
    var actions = MockActions<Action>(expected: [])

    var imageResponse: Result<Data, Error> = .failure(MockError.valueNotSet)

    func load(from url: URL) -> AnyPublisher<Data, Error> {
        register(.loadImage(url))
        return imageResponse.publish()
    }
}
