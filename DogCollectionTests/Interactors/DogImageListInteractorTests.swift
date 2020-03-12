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

class DogImageListInteractorTests: XCTestCase, PublisherTestCase {
    var cancellables: Set<AnyCancellable> = []

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

        assert(expected: [
            .notRequested,
            .isLoading(last: nil, cancelBag: CancelBag()),
            .loaded(expected)
        ], when: { sut.loadDogImages(of: anyBreedType, dogImages: $0) })

        verify(webAPI, store)
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

        assert(initialLoadable: .loaded(initial),
               expected: [
                .loaded(initial),
                .isLoading(last: initial, cancelBag: CancelBag()),
                .loaded(expected),
        ], when: { sut.loadDogImages(of: anyBreedType, dogImages: $0) })

        verify(webAPI, store)
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

        assert(expected: [
            .notRequested,
            .isLoading(last: nil, cancelBag: CancelBag()),
            .failed(expected),
        ], when: { sut.loadDogImages(of: anyBreedType, dogImages: $0) })

        verify(webAPI, store)
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

        assert(expected: [
            .notRequested,
            .isLoading(last: nil, cancelBag: CancelBag()),
            .loaded(expected.map { dogImage in
                if dogImage.imageURL == favoriteDogImage.imageURL {
                    return DogImage(imageURL: dogImage.imageURL, isFavorite: true)
                }
                return dogImage
            }),
        ], when: { sut.loadDogImages(of: anyBreedType, dogImages: $0) })

        verify(webAPI, store)
    }

    // MARK: - Helper

    private func makeSUT() -> (LiveDogImageListInteractor, MockedDogImageListLoader, MockedFavoriteDogImageStore) {
        let webAPI = MockedDogImageListLoader()
        let store  = MockedFavoriteDogImageStore()
        let sut = LiveDogImageListInteractor(loader: webAPI, favoriteDogImageStore: store)
        return (sut, webAPI, store)
    }

    private func verify(_ webAPI: MockedDogImageListLoader,
                        _ store: MockedFavoriteDogImageStore,
                        file: StaticString = #file, line: UInt = #line) {
        webAPI.verify(file: file, line: line)
        store.verify(file: file, line: line)
    }
}
