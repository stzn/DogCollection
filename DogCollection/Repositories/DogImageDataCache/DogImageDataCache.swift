//
//  ImageCache.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/03/01.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

protocol DogImageDataCache {
    typealias Key = URL
    typealias Value = Data
    func cache(_ value: Value, key: Key, expiry: Expiry)
    func cachedImage(for key: Key) -> AnyPublisher<Value, CacheError>
    func purge()
    func purgeExpired()
}
