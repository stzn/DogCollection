//
//  DogImageListFavoriteImageStoreTests.swift
//  DogCollectionTests
//
//  Created by Shinzan Takata on 2020/03/06.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import XCTest
import SwiftUI
@testable import DogCollection

class DogImageListFavoriteImageStoreTests: XCTestCase {
    var cancellables: Set<AnyCancellable> = []

    func test_init_doesNotStoreAny() {
        let (_, store) = makeSUT()
        store.load(of: Breed.anyBreed.name)
            .sinkToResult { result in
                switch result {
                case .success(let data):
                    XCTFail("expect failure but got \(data)")
                case .failure(let error):
                    XCTAssertEqual(error.localizedDescription,
                                   MockError.valueNotSet.localizedDescription)
                }
        }.store(in: &cancellables)
    }

    func test_addFavoriteDogImage_store() {
        let initialDogImage = DogImage.anyDogImage
        let (sut, store) = makeSUT()
        store.actions = .init(expected: [
            .register(initialDogImage.imageURL),
        ])

        assertAddFavorite(sut, store, initialDogImage: initialDogImage, expected: [
            .loaded(initialDogImage),
            .isLoading(last: initialDogImage, cancelBag: CancelBag()),
            .loaded(DogImage(imageURL: initialDogImage.imageURL, isFavorite: true))

        ])
    }

    func test_removeFavoriteDogImage_store() {
        let expected = DogImage.anyDogImage
        let initialDogImage = DogImage(imageURL: expected.imageURL, isFavorite: true)
        let (sut, store) = makeSUT()
        store.actions = .init(expected: [
            .unregister(expected.imageURL),
        ])

        assertRemoveFavorite(sut, store, initialDogImage: initialDogImage, expected: [
            .loaded(initialDogImage),
            .isLoading(last: initialDogImage, cancelBag: CancelBag()),
            .loaded(expected)
        ])
    }

    // MARK: - Helper

    private func makeSUT() -> (LiveDogImageListInteractor, MockedFavoriteDogImageStore) {
        let webAPI = MockedDogImageListLoader()
        webAPI.dogImageListResponse = .success([])
        let store  = MockedFavoriteDogImageStore()
        let sut = LiveDogImageListInteractor(webAPI: webAPI, favoriteDogImageStore: store)
        return (sut, store)
    }

    private func assertAddFavorite(_ sut: DogImageListInteractor,
                        _ store: MockedFavoriteDogImageStore,
                        initialDogImage: DogImage,
                        expected: [Loadable<DogImage>],
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "wait for load")
        let (binding, updatesPublisher) = recordLoadableUpdates(initialDogImage: initialDogImage)
        updatesPublisher.sink { updates in
            XCTAssertEqual(updates, expected, file: file, line: line)
            store.verify(file: file, line: line)
            exp.fulfill()
        }.store(in: &cancellables)

        sut.addFavoriteDogImage(binding)

        wait(for: [exp], timeout: 1.0)
    }

    private func assertRemoveFavorite(_ sut: DogImageListInteractor,
                        _ store: MockedFavoriteDogImageStore,
                        initialDogImage: DogImage,
                        expected: [Loadable<DogImage>],
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "wait for load")
        let (binding, updatesPublisher) = recordLoadableUpdates(initialDogImage: initialDogImage)
        updatesPublisher.sink { updates in
            XCTAssertEqual(updates, expected, file: file, line: line)
            store.verify(file: file, line: line)
            exp.fulfill()
        }.store(in: &cancellables)

        sut.removeFavoriteDogImage(binding)

        wait(for: [exp], timeout: 1.0)
    }

    private func recordLoadableUpdates(
        initialDogImage: DogImage,
        for timeInterval: TimeInterval = 0.5)
        -> (Binding<Loadable<DogImage>>, AnyPublisher<[Loadable<DogImage>], Never>) {
            let initialLoadable: Loadable<DogImage> = .loaded(initialDogImage)
            let publisher = CurrentValueSubject<Loadable<DogImage>, Never>(initialLoadable)
            let binding = Binding(get: { initialLoadable }, set: { publisher.send($0) })
            let updatesPublisher = Future<[Loadable<DogImage>], Never> { promise in
                var updates: [Loadable<DogImage>] = []

                publisher
                    .sink { updates.append($0) }
                    .store(in: &self.cancellables)

                DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
                    promise(.success(updates))
                }
            }.eraseToAnyPublisher()

            return (binding, updatesPublisher)
    }
}
