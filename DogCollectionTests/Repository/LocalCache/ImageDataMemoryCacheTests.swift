//
//  ImageDataMemoryCacheTests.swift
//  DogCollectionTests
//
//  Created by Shinzan Takata on 2020/03/01.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import XCTest
@testable import DogCollection

class ImageDataMemoryCacheTests: XCTestCase {

    var cancellables: Set<AnyCancellable> = []

    func test_cachedImage_IsMissing() {
        let sut = makeSUT()
        let exp = expectation(description: "wait for cache")
        sut.cachedImage(for: anyKey)
            .sinkToResult { result in
                XCTAssertEqual(result, .failure(.isMissing))
                exp.fulfill()
        }.store(in: &cancellables)
        wait(for: [exp], timeout: 1.0)
    }

    func test_cachedImage_CacheImage() {
        let sut = makeSUT()
        let key = anyKey
        let data = anyData
        sut.cache(data: data, key: key)

        let exp = expectation(description: "wait for cache")
        sut.cachedImage(for: key)
            .sinkToResult { result in
                XCTAssertEqual(result, .success(data))
                exp.fulfill()
        }.store(in: &cancellables)
        wait(for: [exp], timeout: 1.0)
    }

    func test_cachedImage_purge() {
        let sut = makeSUT()
        let key = anyKey
        let data = anyData
        sut.cache(data: data, key: key)
        sut.purge()

        let exp = expectation(description: "wait for cache")
        sut.cachedImage(for: key)
            .sinkToResult { result in
                XCTAssertEqual(result, .failure(.isMissing))
                exp.fulfill()
        }.store(in: &cancellables)
        wait(for: [exp], timeout: 1.0)
    }

    func test_cachedImage_purgeExpired() {
        let sut = makeSUT()
        let key = anyKey
        let data = anyData
        sut.cache(data: data, key: key, expiry: .seconds(-1))
        sut.purgeExpired()

        let exp = expectation(description: "wait for cache")
        sut.cachedImage(for: key)
            .sinkToResult { result in
                XCTAssertEqual(result, .failure(.isMissing))
                exp.fulfill()
        }.store(in: &cancellables)
        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helper

    private func makeSUT() -> ImageDataMemoryCache {
        ImageDataMemoryCache(config: .init(expiry: .never))
    }

    private var anyKey: String {
        UUID().uuidString
    }

    private var anyData: Data {
        UIColor.red.image().pngData()!
    }
}
