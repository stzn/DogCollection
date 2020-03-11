//
//  FavoriteDogImageListInteractorTests.swift
//  DogCollectionTests
//
//  Created by Shinzan Takata on 2020/03/11.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import SwiftUI
import XCTest
@testable import DogCollection

class LiveFavoriteDogImageListInteractor: FavoriteDogImageListInteractor {
    let favoriteDogImageStore: FavoriteDogImageURLsStore
    init(favoriteDogImageStore: FavoriteDogImageURLsStore) {
        self.favoriteDogImageStore = favoriteDogImageStore
    }

    func load(dogImages: Binding<Loadable<[BreedType : [DogImage]]>>) {
        let cancelBag = CancelBag()
        dogImages.wrappedValue = .isLoading(last: dogImages.wrappedValue.value, cancelBag: cancelBag)
        favoriteDogImageStore.loadAll()
            .sinkToLoadable { loadable in
                dogImages.wrappedValue = loadable
                    .map { urlsPerBreedType in
                        urlsPerBreedType.mapValues { urls in
                            urls.map { DogImage(imageURL: $0, isFavorite: true) }
                        }
                }
        }.store(in: cancelBag)
    }
}

class FavoriteDogImageListInteractorTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []
    func test_init_noDataLoad() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.actions.factual.count, 0)
    }

    func test_load_notRequested_toLoaded() {
        let (sut, store) = makeSUT()
        let storeData = MockedFavoriteDogImageStore.StoredData(breed: anyBreedType, url: testURL)
        store.actions = .init(expected: [.loadAllFavoriteDogImageURLList])
        store.favoriteAllDogImageURLListResponse = .success([storeData.breed: [storeData.url]])

        assert(sut, store,
               initialLoadable: .notRequested,
               expected: [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded([storeData.breed: [storeData.url.toFavoriteDogImage()]])
            ])
    }

    func test_notRequested_toFailed() {
        let error = anyError
        let (sut, store) = makeSUT()
        store.actions = .init(expected: [.loadAllFavoriteDogImageURLList])
        store.favoriteAllDogImageURLListResponse = .failure(error)

        assert(sut, store,
               initialLoadable: .notRequested,
               expected: [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(error)
            ])
    }

    // MARK: - Helper

    private func makeSUT() -> (LiveFavoriteDogImageListInteractor, MockedFavoriteDogImageStore) {
        let store  = MockedFavoriteDogImageStore()
        let sut = LiveFavoriteDogImageListInteractor(favoriteDogImageStore: store)
        return (sut, store)
    }

    private func assert(_ sut: FavoriteDogImageListInteractor,
                        _ store: MockedFavoriteDogImageStore,
                        initialLoadable: Loadable<[BreedType:[DogImage]]> = .notRequested,
                        expected: [Loadable<[BreedType:[DogImage]]>],
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "wait for load")
        let (binding, updatesPublisher) = recordLoadableUpdates(initialLoadable: initialLoadable)
        updatesPublisher.sink { updates in
            XCTAssertEqual(updates, expected, file: file, line: line)
            store.verify(file: file, line: line)
            exp.fulfill()
        }.store(in: &cancellables)

        sut.load(dogImages: binding)

        wait(for: [exp], timeout: 1.0)
    }

    private func recordLoadableUpdates(initialLoadable: Loadable<[BreedType:[DogImage]]> = .notRequested,
                                       for timeInterval: TimeInterval = 0.5)
        -> (Binding<Loadable<[BreedType:[DogImage]]>>, AnyPublisher<[Loadable<[BreedType:[DogImage]]>], Never>) {
            let publisher = CurrentValueSubject<Loadable<[BreedType:[DogImage]]>, Never>(initialLoadable)
            let binding = Binding(get: { initialLoadable }, set: { publisher.send($0) })
            let updatesPublisher = Future<[Loadable<[BreedType:[DogImage]]>], Never> { promise in
                var updates: [Loadable<[BreedType:[DogImage]]>] = []

                publisher
                    .sink { updates.append($0) }
                    .store(in: &self.cancellables)

                DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
                    promise(.success(updates))
                }
            }.eraseToAnyPublisher()

            return (binding, updatesPublisher)
    }

    //    private func assert(_ sut: LiveFavoriteDogImageListInteractor,
    //                        _ store: MockedFavoriteDogImageStore,
    //                        expectedActions: [MockedFavoriteDogImageStore.Action],
    //                        expectedResult: Result<[BreedType: [DogImage]], Error>,
    //                        file: StaticString = #file, line: UInt = #line) {
    //        let exp = expectation(description: "wait for load")
    //        sut.load().sinkToResult { result in
    //            defer {
    //                exp.fulfill()
    //            }
    //
    //            XCTAssertEqual(store.actions.factual, expectedActions, file: file, line: line)
    //
    //            switch (result, expectedResult) {
    //            case (.success(let received), .success(let expected)):
    //                XCTAssertEqual(received, expected, file: file, line: line)
    //            case (.failure(let received), .failure(let expected)):
    //                XCTAssertEqual(received.localizedDescription, expected.localizedDescription, file: file, line: line)
    //            default:
    //                XCTFail("expected: \(expectedResult), but got \(result)", file: file, line: line)
    //            }
    //        }.store(in: &cancellables)
    //
    //        wait(for: [exp], timeout: 1.0)
    //    }
}

private extension URL {
    func toFavoriteDogImage() -> DogImage {
        DogImage(imageURL: self, isFavorite: true)
    }
}
