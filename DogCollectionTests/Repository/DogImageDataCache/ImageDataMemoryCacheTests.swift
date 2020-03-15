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

        expect(sut, .failure(.isMissing), for: anyKey)
    }

    func test_cachedImage_CacheImage() {
        let sut = makeSUT()
        let key = anyKey
        let data = anyData

        sut.cache(data, key: key, expiry: .never)

        expect(sut, .success(data), for: key)
    }

    func test_cachedImage_purge() {
        let sut = makeSUT()
        let key = anyKey
        sut.cache(anyData, key: key, expiry: .seconds(0))

        sut.purge()

        expect(sut, .failure(.isMissing), for: key)
    }

    func test_cachedImage_purgeExpired() {
        let sut = makeSUT()
        let key = anyKey
        sut.cache(anyData, key: key, expiry: .seconds(-1))

        sut.purgeExpired()

        expect(sut, .failure(.isMissing), for: key)
    }

    // MARK: - Helper

    private func makeSUT() -> ImageDataMemoryCache {
        ImageDataMemoryCache()
    }

    private func expect(_ sut: ImageDataMemoryCache, _ expected: Result<Data, CacheError>, for key: URL) {
        let exp = expectation(description: "wait for cache")
        sut.cachedImage(for: key)
            .sinkToResult { result in
                XCTAssertEqual(result, expected)
                exp.fulfill()
        }.store(in: &cancellables)
        wait(for: [exp], timeout: 1.0)
    }
}
