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

    func test_load_notRequested_to_Loaded() {
        let expected = [DogImage.anyDogImage]
        let (sut, webAPI, store) = makeSUT()
        webAPI.dogImageListResponse = .success(expected)
        webAPI.actions = .init(expected: [
            .loadDogImageList
        ])
        store.favoriteDogImageURLListResponse = .success([])
        store.actions = .init(expected: [
            .loadFavoriteDogImageURLList
        ])

        assert(sut, webAPI, store,
               expected: [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(expected)
        ])
    }

    func test_load_loaded_to_Loaded() {
        let initial = [DogImage.anyDogImage, DogImage.anyDogImage]
        let expected = [DogImage.anyDogImage, DogImage.anyDogImage]
        let (sut, webAPI, store) = makeSUT()
        webAPI.dogImageListResponse = .success(expected)
        webAPI.actions = .init(expected: [
            .loadDogImageList
        ])
        store.favoriteDogImageURLListResponse = .success([])
        store.actions = .init(expected: [
            .loadFavoriteDogImageURLList
        ])
        assert(sut, webAPI, store,
               initialLoadable: .loaded(initial),
               expected: [
                .loaded(initial),
                .isLoading(last: initial, cancelBag: CancelBag()),
                .loaded(expected),
        ])
    }

    func test_load_notRequested_to_WebAPIFailed() {
        let expected = HTTPClientError.invalidResponse(nil)
        let (sut, webAPI, store) = makeSUT()
        webAPI.dogImageListResponse = .failure(HTTPClientError.invalidResponse(nil))
        webAPI.actions = .init(expected: [
            .loadDogImageList
        ])
        store.favoriteDogImageURLListResponse = .success([])
        store.actions = .init(expected: [
            .loadFavoriteDogImageURLList
        ])
        assert(sut, webAPI, store,
               expected: [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(expected),
        ])
    }

    func test_load_includeFavoriteDogImage() {
        let favoriteDogImage = DogImage.anyDogImage
        let expected = [DogImage.anyDogImage, favoriteDogImage]
        let (sut, webAPI, store) = makeSUT()
        webAPI.dogImageListResponse = .success(expected)
        webAPI.actions = .init(expected: [
            .loadDogImageList
        ])
        store.favoriteDogImageURLListResponse = .success(Set([favoriteDogImage.imageURL]))
        store.actions = .init(expected: [
            .loadFavoriteDogImageURLList
        ])
        assert(sut, webAPI, store,
               expected: [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(expected.map { dogImage in
                    if dogImage.imageURL == favoriteDogImage.imageURL {
                        return DogImage(imageURL: dogImage.imageURL, isFavorite: true)
                    }
                    return dogImage
                }),
        ])
    }

    // MARK: - Helper

    private func makeSUT() -> (LiveDogImageListInteractor, MockedDogImageListLoader, MockedFavoriteDogImageStore) {
        let webAPI = MockedDogImageListLoader()
        let store  = MockedFavoriteDogImageStore()
        let sut = LiveDogImageListInteractor(loader: webAPI, favoriteDogImageStore: store)
        return (sut, webAPI, store)
    }

    private func assert(_ sut: DogImageListInteractor,
                        _ webAPI: MockedDogImageListLoader,
                        _ store: MockedFavoriteDogImageStore,
                        initialLoadable: Loadable<[DogImage]> = .notRequested,
                        expected: [Loadable<[DogImage]>],
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "wait for load")
        let (binding, updatesPublisher) = recordLoadableUpdates(initialLoadable: initialLoadable)
        updatesPublisher.sink { updates in
            XCTAssertEqual(updates, expected, file: file, line: line)
            webAPI.verify(file: file, line: line)
            store.verify(file: file, line: line)
            exp.fulfill()
        }.store(in: &cencellables)

        sut.loadDogImages(of: "test", dogImages: binding)

        wait(for: [exp], timeout: 1.0)
    }

    private func recordLoadableUpdates(
        initialLoadable: Loadable<[DogImage]> = .notRequested,
        for timeInterval: TimeInterval = 0.5)
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
