//
//  BreedListInteractorTests.swift
//  DogCollectionTests
//
//  Created by Shinzan Takata on 2020/02/28.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import XCTest
import SwiftUI
@testable import DogCollection

class BreedListInteractorTests: XCTestCase {
    var cencellables: Set<AnyCancellable> = []
    var binding: Binding<Loadable<[Breed]>>!

    func test_load_notRequested_to_Loaded() {
        let expected = [Breed.anyBreed]
        let (sut, webAPI) = makeSUT()
        webAPI.breedListResponse = .success(expected)
        webAPI.actions = .init(expected: [
            .loadBreedList
        ])
        assert(sut, webAPI, expected: [
            .notRequested,
            .isLoading(last: nil, cancelBag: CancelBag()),
            .loaded(expected)
        ])
    }

    func test_load_loaded_to_Loaded() {
        let initial = [Breed.anyBreed, Breed.anyBreed]
        let expected = [Breed.anyBreed, Breed.anyBreed]
        let (sut, webAPI) = makeSUT()
        webAPI.breedListResponse = .success(expected)
        webAPI.actions = .init(expected: [
            .loadBreedList
        ])
        assert(sut, webAPI,
               initialLoadable: .loaded(initial),
               expected: [
                .loaded(initial),
                .isLoading(last: initial, cancelBag: CancelBag()),
                .loaded(expected),
        ])
    }

    func test_load_notRequested_to_Failed() {
        let expected = WebAPIError.invalidResponse(nil)
        let (sut, webAPI) = makeSUT()
        webAPI.breedListResponse = .failure(WebAPIError.invalidResponse(nil))
        webAPI.actions = .init(expected: [
            .loadBreedList
        ])
        assert(sut, webAPI,
               expected: [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(expected),
        ])
    }

    // MARK: - Helper

    private func makeSUT() -> (LiveBreedListInteractor, MockedBreedListLoader) {
        let webAPI = MockedBreedListLoader()
        let sut = LiveBreedListInteractor(webAPI: webAPI)
        return (sut, webAPI)
    }

    private func assert(_ sut: BreedListInteractor,
                        _ webAPI: MockedBreedListLoader,
                        initialLoadable: Loadable<[Breed]> = .notRequested,
                        expected: [Loadable<[Breed]>],
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "wait for load")
        let (binding, updatesPublisher) = recordLoadableUpdates(initialLoadable: initialLoadable)
        updatesPublisher.sink { updates in
            XCTAssertEqual(updates, expected, file: file, line: line)
            webAPI.verify(file: file, line: line)
            exp.fulfill()
        }.store(in: &cencellables)

        sut.load(breedList: binding)

        wait(for: [exp], timeout: 1.0)
    }

    private func recordLoadableUpdates(initialLoadable: Loadable<[Breed]> = .notRequested,
                                       for timeInterval: TimeInterval = 0.5)
        -> (Binding<Loadable<[Breed]>>, AnyPublisher<[Loadable<[Breed]>], Never>) {
            let publisher = CurrentValueSubject<Loadable<[Breed]>, Never>(initialLoadable)
            let binding = Binding(get: { initialLoadable }, set: { publisher.send($0) })
            let updatesPublisher = Future<[Loadable<[Breed]>], Never> { promise in
                var updates: [Loadable<[Breed]>] = []
                
                publisher
                    .sink { updates.append($0) }
                    .store(in: &self.cencellables)

                DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
                    promise(.success(updates))
                }
            }.eraseToAnyPublisher()

            return (binding, updatesPublisher)
    }
}
