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

class FavoriteDogImageListInteractorTests: XCTestCase, PublisherTestCase {
    var cancellables: Set<AnyCancellable> = []
    func test_init_noDataLoad() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.actions.factual.count, 0)
    }

    func test_load_notRequested_toLoaded() {
        let (sut, store) = makeSUT()
        let storeData = MockedFavoriteDogImageStore.StoredData(breed: anyBreedType, url: testURL)
        store.actions = .init(expected: [.loadAllFavoriteDogImageURLList])
        store.favoriteAllDogImageURLListResponse = .success([storeData.breed: [storeData.url]])

        assert(expected: [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded([storeData.breed: [storeData.url.toFavoriteDogImage()]])
        ], when: { sut.load(dogImages: $0) })

        store.verify()
    }

    func test_notRequested_toFailed() {
        let error = anyError
        let (sut, store) = makeSUT()
        store.actions = .init(expected: [.loadAllFavoriteDogImageURLList])
        store.favoriteAllDogImageURLListResponse = .failure(error)

        assert(expected: [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(error)
        ], when: { sut.load(dogImages: $0) })

        store.verify()
    }

    // MARK: - Helper

    private func makeSUT() -> (LiveFavoriteDogImageListInteractor, MockedFavoriteDogImageStore) {
        let store  = MockedFavoriteDogImageStore()
        let sut = LiveFavoriteDogImageListInteractor(favoriteDogImageStore: store)
        return (sut, store)
    }
}

private extension URL {
    func toFavoriteDogImage() -> DogImage {
        DogImage(imageURL: self, isFavorite: true)
    }
}
