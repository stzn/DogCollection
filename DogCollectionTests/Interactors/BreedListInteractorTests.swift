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

class BreedListInteractorTests: XCTestCase, PublisherTestCase {
    var cancellables: Set<AnyCancellable> = []
    var binding: Binding<Loadable<[Breed]>>!

    func test_load_notRequested_to_Loaded() {
        let expected = [Breed.anyBreed]
        let (sut, webAPI) = makeSUT()
        webAPI.breedListResponse = .success(expected)
        webAPI.actions = .init(expected: [
            .loadBreedList
        ])

        assert(expected: [
            .notRequested,
            .isLoading(last: nil, cancelBag: CancelBag()),
            .loaded(expected)
        ], when: { sut.load(breedList: $0) })

        webAPI.verify()
    }

    func test_load_loaded_to_Loaded() {
        let initial = [Breed.anyBreed, Breed.anyBreed]
        let expected = [Breed.anyBreed, Breed.anyBreed]
        let (sut, webAPI) = makeSUT()
        webAPI.breedListResponse = .success(expected)
        webAPI.actions = .init(expected: [
            .loadBreedList
        ])

        assert(initialLoadable: .loaded(initial),
               expected: [
                .loaded(initial),
                .isLoading(last: initial, cancelBag: CancelBag()),
                .loaded(expected),
        ], when: { sut.load(breedList: $0) })

        webAPI.verify()
    }

    func test_load_notRequested_to_Failed() {
        let expected = HTTPClientError.invalidResponse(nil)
        let (sut, webAPI) = makeSUT()
        webAPI.breedListResponse = .failure(HTTPClientError.invalidResponse(nil))
        webAPI.actions = .init(expected: [
            .loadBreedList
        ])

        assert(expected: [
            .notRequested,
            .isLoading(last: nil, cancelBag: CancelBag()),
            .failed(expected),
        ], when: { sut.load(breedList: $0) })

        webAPI.verify()
    }

    // MARK: - Helper

    private func makeSUT() -> (LiveBreedListInteractor, MockedBreedListLoader) {
        let webAPI = MockedBreedListLoader()
        let sut = LiveBreedListInteractor(loader: webAPI)
        return (sut, webAPI)
    }
}
