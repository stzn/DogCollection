//
//  ImageCache.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/03/01.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation


protocol ImageDataCache {
    typealias Key = String
    func cache(data: Data, key: Key, expiry: Expiry?)
    func cachedImage(for key: Key) -> AnyPublisher<Data, ImageDataCacheError>
    func purge()
}

enum ImageDataCacheError: Error {
    case isMissing
}
