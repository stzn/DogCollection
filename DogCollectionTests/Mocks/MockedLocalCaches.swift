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

final class MockedImageDataCache: DogImageDataCache, Mock {
    enum Action: Equatable {
        case loadData(DogImageDataCache.Key)
    }

    var actions = MockActions<Action>(expected: [])
    var imageResponse: Result<Data, DogImageDataCacheError> = .failure(.isMissing)
    private(set) var cache: [DogImageDataCache.Key: (Data, Expiry?)] = [:]
    private(set) var didPurgeCalled = false
    private(set) var didPurgeExpiredCalled = false

    func cache(data: Data, key: Key, expiry: Expiry?) {
        cache[key] = (data, expiry)
    }

    func cachedImage(for key: Key) -> AnyPublisher<Data, DogImageDataCacheError> {
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
            let (_, expiry) = value
            if expiry?.isExpired ?? false {
                cache[key] = nil
            }
        }
    }
}
