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

class ImageDataInteractorTests: XCTestCase {

    var cencellables: Set<AnyCancellable> = []

    func test_load_fromWebAPI() {
        let expected = anyData
        let (sut, webAPI, cache) = makeSUT()

        webAPI.imageResponse = .success(expected)

        expect(webAPI, cache,
               webAPIExp: [.loadImage(testURL)],
               cacheExp: [.loadData(testURL.absoluteString)])
        assert(sut, webAPI, cache, expected: [
            .notRequested,
            .isLoading(last: nil, cancelBag: CancelBag()),
            .loaded(expected)
        ])
    }

    func test_load_fromCache() {
        let expected = anyData
        let (sut, webAPI, cache) = makeSUT()

        cache.imageResponse = .success(expected)

        expect(webAPI, cache,
               webAPIExp: [],
               cacheExp: [.loadData(testURL.absoluteString)])

        cache.cache(data: expected, key: testURL.absoluteString, expiry: nil)

        assert(sut, webAPI, cache, expected: [
            .notRequested,
            .isLoading(last: nil, cancelBag: CancelBag()),
            .loaded(expected)
        ])
    }

    func test_load_invalidWebResponse_failed() {
        let expected = anyError
        let (sut, webAPI, cache) = makeSUT()

        webAPI.imageResponse = .failure(expected)

        expect(webAPI, cache,
               webAPIExp: [.loadImage(testURL)],
               cacheExp: [.loadData(testURL.absoluteString)])

        assert(sut, webAPI, cache, expected: [
            .notRequested,
            .isLoading(last: nil, cancelBag: CancelBag()),
            .failed(expected)
        ])
    }

    // MARK: - Helper

    private func makeSUT() -> (LiveImageDataInteractor, MockedImageDataWebAPILoader, MockedImageDataCache) {
        let webAPI = MockedImageDataWebAPILoader()
        let cache = MockedImageDataCache()
        let sut = LiveImageDataInteractor(webAPI: webAPI, cache: cache)
        return (sut, webAPI, cache)
    }

    private func expect(
        _ webAPI: MockedImageDataWebAPILoader,
        _ cache: MockedImageDataCache,
        webAPIExp: [MockedImageDataWebAPILoader.Action],
        cacheExp: [MockedImageDataCache.Action]) {

        webAPI.actions = .init(expected: webAPIExp)
        cache.actions = .init(expected: cacheExp)
    }

    private func verify(_ webAPI: MockedImageDataWebAPILoader,
                        _ cache: MockedImageDataCache,
                        file: StaticString = #file, line: UInt = #line) {
        webAPI.verify(file: file, line: line)
        cache.verify(file: file, line: line)
    }

    private func assert(_ sut: LiveImageDataInteractor,
                        _ webAPI: MockedImageDataWebAPILoader,
                        _ cache: MockedImageDataCache,
                        initialLoadable: Loadable<Data> = .notRequested,
                        expected: [Loadable<Data>],
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "wait for load")
        let (binding, updatesPublisher) = recordLoadableUpdates(initialLoadable: initialLoadable)
        updatesPublisher.sink { updates in
            XCTAssertEqual(updates, expected, file: file, line: line)
            self.verify(webAPI, cache, file: file, line: line)
            exp.fulfill()
        }.store(in: &cencellables)

        sut.load(from: testURL, image: binding)

        wait(for: [exp], timeout: 1.0)
    }

    private func recordLoadableUpdates(
        initialLoadable: Loadable<Data> = .notRequested,
        for timeInterval: TimeInterval = 0.5)
        -> (Binding<Loadable<Data>>, AnyPublisher<[Loadable<Data>], Never>) {
            let publisher = CurrentValueSubject<Loadable<Data>, Never>(initialLoadable)
            let binding = Binding(get: { initialLoadable }, set: { publisher.send($0) })
            let updatesPublisher = Future<[Loadable<Data>], Never> { promise in
                var updates: [Loadable<Data>] = []

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
