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

    var cancellables: Set<AnyCancellable> = []

    func test_load_fromWebAPI() {
        let expected = anyData
        let (sut, webAPI, cache, _) = makeSUT()

        webAPI.imageResponse = .success(expected)

        expect(webAPI, cache,
               webAPIExp: [.loadImage(testURL)],
               cacheExp: [.loadData(testURL)])
        assert(sut, webAPI, cache, expected: [
            .notRequested,
            .isLoading(last: nil, cancelBag: CancelBag()),
            .loaded(expected)
        ])
    }

    func test_load_fromCache() {
        let expected = anyData
        let (sut, webAPI, cache, _) = makeSUT()

        cache.imageResponse = .success(expected)

        expect(webAPI, cache,
               webAPIExp: [],
               cacheExp: [.loadData(testURL)])

        cache.cache(expected, key: testURL, expiry: .seconds(0))

        assert(sut, webAPI, cache, expected: [
            .notRequested,
            .isLoading(last: nil, cancelBag: CancelBag()),
            .loaded(expected)
        ])
    }

    func test_load_invalidWebResponse_failed() {
        let expected = anyError
        let (sut, webAPI, cache, _) = makeSUT()

        webAPI.imageResponse = .failure(expected)

        expect(webAPI, cache,
               webAPIExp: [.loadImage(testURL)],
               cacheExp: [.loadData(testURL)])

        assert(sut, webAPI, cache, expected: [
            .notRequested,
            .isLoading(last: nil, cancelBag: CancelBag()),
            .failed(expected)
        ])
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
                                              cachePolicy: CachePolicy(expiry: .never),
                                              memoryWarning: memoryWarning.eraseToAnyPublisher())
            return (sut, webAPI, cache, memoryWarning)
    }

    private func expect(
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

    private func assert(_ sut: LiveImageDataInteractor,
                        _ webAPI: MockedImageDataLoader,
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
        }.store(in: &cancellables)

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
                    .store(in: &self.cancellables)

                DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
                    promise(.success(updates))
                }
            }.eraseToAnyPublisher()

            return (binding, updatesPublisher)
    }

}
