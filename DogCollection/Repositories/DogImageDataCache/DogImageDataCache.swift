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
    typealias Key = String
    func cache(data: Data, key: Key, expiry: Expiry?)
    func cachedImage(for key: Key) -> AnyPublisher<Data, DogImageDataCacheError>
    func purge()
    func purgeExpired()
}

enum DogImageDataCacheError: Error {
    case isMissing
}
