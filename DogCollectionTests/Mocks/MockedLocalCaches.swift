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
    var imageResponse: Result<Data, ImageDataCacheError> = .failure(.isMissing)
    var cache: [ImageDataCache.Key: Data] = [:]
    var didPurgeCalled = false

    func cache(data: Data, key: Key, expiry: Expiry?) {
        cache[key] = data
    }

    func cachedImage(for key: Key) -> AnyPublisher<Data, ImageDataCacheError> {
        register(.loadData(key))
        return imageResponse.publish()
    }

    func purge() {
        didPurgeCalled = true
    }
}
