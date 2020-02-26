//
//  DogImageListViewModelTests.swift
//  DogCollectionTests
//
//  Created by Shinzan Takata on 2020/02/24.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import XCTest
@testable import DogCollection

class DogImageListViewModelTests: XCTestCase {
    var cancellables: Set<AnyCancellable> = []

    func test_init_noDataGot() {
        let (sut, _) = makeSUT()
        XCTAssertTrue(sut.dogImages.isEmpty)
    }

    func test_get_dataGotOnSuccess() {
        let expected = [DogImage.anyDogImage]
        let publisher = createSuccessPublisher(with: expected)
        let (sut, api) = makeSUT(with: publisher)

        let exp = expectation(description: "wait for get")
        sut.$state.dropFirst().sink { state in
            XCTAssertEqual(state, .loaded)
            XCTAssertEqual(sut.dogImages, expected)
            exp.fulfill()
        }.store(in: &cancellables)

        sut.get(api: api)

        wait(for: [exp], timeout: 1.0)
    }

    func test_get_errorDeliveredOnError() {
        let expected = WebAPIError.unhandledResponse
        let publisher = createErrorPublisher(with: expected)
        let (sut, api) = makeSUT(with: publisher)

        let exp = expectation(description: "wait for get")
        sut.$state.dropFirst().sink { state in
            XCTAssertEqual(state, .error)
            XCTAssertEqual(sut.error, expected.localizedDescription)
            exp.fulfill()
        }.store(in: &cancellables)

        sut.get(api: api)

        wait(for: [exp], timeout: 1.0)
    }

    private func makeSUT(with publisher: AnyPublisher<[DogImage], Error> = empty) -> (DogImageListViewModel, DogImageListLoaderStub) {
        let api = DogImageListLoaderStub(publisher: publisher)
        let sut = DogImageListViewModel(breed: "test")
        return (sut, api)
    }

    private static let empty: AnyPublisher<[DogImage], Error> =
        Empty().setFailureType(to: Error.self).eraseToAnyPublisher()

    private func createSuccessPublisher(with breeds: [DogImage]) -> AnyPublisher<[DogImage], Error> {
        Just(breeds).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    private func createErrorPublisher(with error: Error) -> AnyPublisher<[DogImage], Error> {
        Fail<[DogImage], Error>(error: error).eraseToAnyPublisher()
    }
}

class DogImageListLoaderStub: DogImageListLoader {
    private let publisher: AnyPublisher<[DogImage], Error>
    init(publisher: AnyPublisher<[DogImage], Error>) {
        self.publisher = publisher
    }

    func load(breed: String) -> AnyPublisher<[DogImage], Error> {
        publisher
    }
}
