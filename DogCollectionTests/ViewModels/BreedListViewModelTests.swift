//
//  BreedListViewModelTests.swift
//  DogCollectionTests
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import XCTest
@testable import DogCollection

class BreedListViewModelTests: XCTestCase {
    var cancellables: Set<AnyCancellable> = []
    
    func test_init_noDataGot() {
        let (sut, _) = makeSUT()
        XCTAssertTrue(sut.breeds.isEmpty)
    }
    
    func test_get_dataGotOnSuccess() {
        let expected = [Breed.anyBreed]
        let publisher = createSuccessPublisher(with: expected)
        let (sut, api) = makeSUT(with: publisher)
        
        let exp = expectation(description: "\(#function)")
        sut.$state.dropFirst(2).sink { state in
            XCTAssertEqual(state, .loaded)
            XCTAssertEqual(sut.breeds, expected)
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
        sut.$state.dropFirst(2).sink { state in
            XCTAssertEqual(state, .error)
            XCTAssertEqual(sut.error, expected.localizedDescription)
            exp.fulfill()
        }.store(in: &cancellables)

        sut.get(api: api)

        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(with publisher: AnyPublisher<[Breed], Error> = empty) -> (BreedListViewModel, BreedListGettable) {
        let api = BreedListGettableStub(publisher: publisher)
        let sut = BreedListViewModel()
        return (sut, api)
    }
    
    private static let empty: AnyPublisher<[Breed], Error> =
        Empty().setFailureType(to: Error.self).eraseToAnyPublisher()
    
    private func createSuccessPublisher(with breeds: [Breed]) -> AnyPublisher<[Breed], Error> {
        Just(breeds).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    private func createErrorPublisher(with error: Error) -> AnyPublisher<[Breed], Error> {
        Fail<[Breed], Error>(error: error).eraseToAnyPublisher()
    }
}

class BreedListGettableStub: BreedListGettable {
    private let publisher: AnyPublisher<[Breed], Error>
    init(publisher: AnyPublisher<[Breed], Error>) {
        self.publisher = publisher
    }
    
    func get() -> AnyPublisher<[Breed], Error> {
        publisher
    }
}
