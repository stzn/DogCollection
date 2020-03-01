//
//  DogImageListInteractorTests.swift
//  DogCollectionTests
//
//  Created by Shinzan Takata on 2020/02/28.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import XCTest
import SwiftUI
@testable import DogCollection

class DogImageListInteractorTests: XCTestCase {
    var cencellables: Set<AnyCancellable> = []
    var binding: Binding<Loadable<[DogImage]>>!

    func test_load_notRequested_to_Loaded() {
        let expected = [DogImage.anyDogImage]
        let (sut, webAPI) = makeSUT()
        webAPI.dogImageListResponse = .success(expected)
        webAPI.actions = .init(expected: [
            .loadDogImageList
        ])
        assert(sut, webAPI, expected: [
            .notRequested,
            .isLoading(last: nil, cancelBag: CancelBag()),
            .loaded(expected)
        ])
    }

    func test_load_loaded_to_Loaded() {
        let initial = [DogImage.anyDogImage, DogImage.anyDogImage]
        let expected = [DogImage.anyDogImage, DogImage.anyDogImage]
        let (sut, webAPI) = makeSUT()
        webAPI.dogImageListResponse = .success(expected)
        webAPI.actions = .init(expected: [
            .loadDogImageList
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
        webAPI.dogImageListResponse = .failure(WebAPIError.invalidResponse(nil))
        webAPI.actions = .init(expected: [
            .loadDogImageList
        ])
        assert(sut, webAPI,
               expected: [
            .notRequested,
            .isLoading(last: nil, cancelBag: CancelBag()),
            .failed(expected),
        ])
    }

    // MARK: - Helper

    private func makeSUT() -> (LiveDogImageListInteractor, MockedDogImageListLoader) {
        let webAPI = MockedDogImageListLoader()
        let sut = LiveDogImageListInteractor(webAPI: webAPI)
        return (sut, webAPI)
    }

    private func assert(_ sut: DogImageListInteractor,
                        _ webAPI: MockedDogImageListLoader,
                        initialLoadable: Loadable<[DogImage]> = .notRequested,
                        expected: [Loadable<[DogImage]>]) {
        let exp = expectation(description: "wait for load")
        let (binding, updatesPublisher) = recordLoadableUpdates(initialLoadable: initialLoadable)
        updatesPublisher.sink { updates in
            XCTAssertEqual(updates, expected)
            webAPI.verify()
            exp.fulfill()
        }.store(in: &cencellables)

        sut.loadDogImages(of: "test", dogImages: binding)

        wait(for: [exp], timeout: 1.0)
    }

    private func recordLoadableUpdates(initialLoadable: Loadable<[DogImage]> = .notRequested, for timeInterval: TimeInterval = 0.5)
        -> (Binding<Loadable<[DogImage]>>, AnyPublisher<[Loadable<[DogImage]>], Never>) {
            let publisher = CurrentValueSubject<Loadable<[DogImage]>, Never>(initialLoadable)
            let binding = Binding(get: { initialLoadable }, set: { publisher.send($0) })
            let updatesPublisher = Future<[Loadable<[DogImage]>], Never> { promise in
                var updates: [Loadable<[DogImage]>] = []

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
