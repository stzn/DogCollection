//
//  SystemEventsHandlerTests.swift
//  DogCollectionTests
//
//  Created by Shinzan Takata on 2020/03/02.
//  Copyright © 2020 shiz. All rights reserved.
//

import XCTest
@testable import DogCollection

class SystemEventsHandlerTests: XCTestCase {

    func test_didBecomeActive() {
        let (sut, cache) = makeSUT()
        XCTAssertEqual(cache.cache.count, 0)
        XCTAssertFalse(sut.appState[\.system].isActive)

        sut.sceneDidBecomeActive()

        XCTAssertTrue(sut.appState[\.system].isActive)
        XCTAssertTrue(cache.didPurgeExpiredCalled)
    }

    func test_didBecomeActive_withCache() {
        let (sut, cache) = makeSUT()
        cache.cache(anyData, key: anyKey, expiry: .never)
        cache.cache(anyData, key: anyKey, expiry: .seconds(-1))

        XCTAssertEqual(cache.cache.count, 2)
        XCTAssertFalse(sut.appState[\.system].isActive)

        sut.sceneDidBecomeActive()

        XCTAssertTrue(sut.appState[\.system].isActive)
        XCTAssertTrue(cache.didPurgeExpiredCalled)
        XCTAssertEqual(cache.cache.count, 1)
    }

    func test_willResignActive() {
        let (sut, _) = makeSUT()
        sut.sceneDidBecomeActive()
        sut.sceneWillResignActive()
        let reference = AppState()
        XCTAssertEqual(sut.appState.value, reference)
    }

    // MARK: - Helper

    private func makeSUT() -> (LiveSystemEventsHandler, MockedImageDataCache) {
        let cache = MockedImageDataCache()
        let sut = LiveSystemEventsHandler(appState: .init(AppState()), caches: [cache])
        return (sut, cache)
    }
}
