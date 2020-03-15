//
//  MockedLocalCaches.swift
//  DogCollectionTests
//
//  Created by Shinzan Takata on 2020/03/01.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation
@testable import DogCollection

final class MockedImageDataCache: ImageDataCache, Mock {
    enum Action: Equatable {
        case loadData(ImageDataCache.Key)
    }

    var actions = MockActions<Action>(expected: [])
    var imageResponse: Result<Data, CacheError> = .failure(.isMissing)
    private(set) var cache: [ImageDataCache.Key: (value: Data, expirationDate: Date)] = [:]
    private(set) var didPurgeCalled = false
    private(set) var didPurgeExpiredCalled = false

    func cache(_ value: Value, key: Key, expiry: Expiry) {
        cache[key] = (value, expiry.date)
    }

    func cachedImage(for key: Key) -> AnyPublisher<Value, CacheError> {
        register(.loadData(key))
        return imageResponse.publish()
    }

    func purge() {
        didPurgeCalled = true
        cache = [:]
    }

    func purgeExpired() {
        didPurgeExpiredCalled = true
        cache.forEach { (key, value) in
            if value.expirationDate.timeIntervalSinceNow < 0 {
                cache[key] = nil
            }
        }
    }
}
