//
//  ImageDataInteractorTests.swift
//  DogCollectionTests
//
//  Created by Shinzan Takata on 2020/03/01.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import SwiftUI
import XCTest
@testable import DogCollection

class ImageDataInteractorTests: XCTestCase, PublisherTestCase {

    var cancellables: Set<AnyCancellable> = []

    func test_load_fromWebAPI() {
        let expected = anyData
        let (sut, webAPI, cache, _) = makeSUT()

        webAPI.imageResponse = .success(expected)

        setExpect(webAPI, cache,
               webAPIExp: [.loadImage(testURL)],
               cacheExp: [.loadData(testURL)])

        assert(expected: [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(expected)
        ], when: { sut.load(from: testURL, image: $0) })

        verify(webAPI, cache)
    }

    func test_load_fromCache() {
        let expected = anyData
        let (sut, webAPI, cache, _) = makeSUT()

        cache.imageResponse = .success(expected)

        setExpect(webAPI, cache,
               webAPIExp: [],
               cacheExp: [.loadData(testURL)])

        cache.cache(expected, key: testURL, expiry: .seconds(0))

        assert(expected: [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(expected)
        ], when: { sut.load(from: testURL, image: $0) })

        verify(webAPI, cache)
    }

    func test_load_invalidWebResponse_failed() {
        let expected = anyError
        let (sut, webAPI, cache, _) = makeSUT()

        webAPI.imageResponse = .failure(expected)

        setExpect(webAPI, cache,
               webAPIExp: [.loadImage(testURL)],
               cacheExp: [.loadData(testURL)])

        assert(expected: [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(expected)
        ], when: { sut.load(from: testURL, image: $0) })

        verify(webAPI, cache)
    }

    func test_memoryWarning_purgeCache() {
        let expected = anyData
        let (sut, _, cache, memoryWarning) = makeSUT()
        _ = sut // this is to stop warning
        cache.cache(expected, key: testURL, expiry: .seconds(0))
        XCTAssertFalse(cache.didPurgeCalled)
        memoryWarning.send(())
        XCTAssertTrue(cache.didPurgeCalled)
    }

    // MARK: - Helper

    private func makeSUT() -> (LiveImageDataInteractor, MockedImageDataLoader,
        MockedImageDataCache, PassthroughSubject<Void, Never>) {
            let webAPI = MockedImageDataLoader()
            let cache = MockedImageDataCache()
            let memoryWarning = PassthroughSubject<Void, Never>()
            let sut = LiveImageDataInteractor(loader: webAPI, cache: cache,
                                              cachePolicy: ImageDataCachePolicy(expiry: .never),
                                              memoryWarning: memoryWarning.eraseToAnyPublisher())
            return (sut, webAPI, cache, memoryWarning)
    }

    private func setExpect(
        _ webAPI: MockedImageDataLoader,
        _ cache: MockedImageDataCache,
        webAPIExp: [MockedImageDataLoader.Action],
        cacheExp: [MockedImageDataCache.Action]) {

        webAPI.actions = .init(expected: webAPIExp)
        cache.actions = .init(expected: cacheExp)
    }

    private func verify(_ webAPI: MockedImageDataLoader,
                        _ cache: MockedImageDataCache,
                        file: StaticString = #file, line: UInt = #line) {
        webAPI.verify(file: file, line: line)
        cache.verify(file: file, line: line)
    }
}
