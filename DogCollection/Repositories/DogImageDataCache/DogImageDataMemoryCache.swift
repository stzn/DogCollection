//
//  ImageMemoryCache.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/03/01.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

typealias DogImageDataMemoryCache = MemoryCache<DogImageDataCache.Key, DogImageDataCache.Value>

extension MemoryCache: DogImageDataCache where Key == URL, Value == Data {
    func cache(_ value: Data, key: Key, expiry: Expiry) {
        self.insert(value, for: key, expiry: expiry)
    }

    func cachedImage(for key: Key) -> AnyPublisher<Value, CacheError> {
        self.value(for: key)
    }
}
