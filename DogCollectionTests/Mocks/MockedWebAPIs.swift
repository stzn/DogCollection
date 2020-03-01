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

final class WebAPIClientStub: WebAPIClient {
    var publisher: AnyPublisher<Response, WebAPIError>!
    private init(publisher: AnyPublisher<Response, WebAPIError>) {
        self.publisher = publisher
    }

    static func output(response: Response) -> WebAPIClient {
        let publisher = Just(response).setFailureType(to: WebAPIError.self).eraseToAnyPublisher()
        return Self(publisher: publisher)
    }

    static func failure(error: WebAPIError) -> WebAPIClient {
        let publisher = Fail<Response, WebAPIError>(error: error).eraseToAnyPublisher()
        return Self(publisher: publisher)
    }

    func send(request: URLRequest) -> AnyPublisher<Response, WebAPIError> {
        publisher
    }
}

class TestWebAPI: WebAPI {
    var client: WebAPIClient = WebAPIClientStub.output(response: Response(data: Data(), response: okResponse))
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

    func loadDogImages(of breed: String) -> AnyPublisher<[DogImage], Error> {
        register(.loadDogImageList)
        return dogImageListResponse.publish()
    }
}

final class MockedImageDataWebAPILoader: TestWebAPI, Mock, ImageDataLoader {
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
