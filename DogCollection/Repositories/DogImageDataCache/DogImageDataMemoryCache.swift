//
//  ImageMemoryCache.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/03/01.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

final class DogImageDataMemoryCache: DogImageDataCache {
    private let cache = NSCache<NSString, CacheObject>()
    private var keys: Set<String> = []
    private let config: Config

    init(config: Config = Config()) {
        self.config = config
        self.cache.countLimit = Int(config.countLimit)
        self.cache.totalCostLimit = Int(config.totalCostLimit)
    }

    func cache(data: Data, key: DogImageDataCache.Key, expiry: Expiry? = nil) {
        let cacheObject = CacheObject(value: data, expiry: expiry ?? config.expiry)
        cache.setObject(cacheObject, forKey: NSString(string: key), cost: data.count)
        keys.insert(key)
    }

    func cachedImage(for key: DogImageDataCache.Key) -> AnyPublisher<Data, DogImageDataCacheError> {
        guard let cache = cache.object(forKey: NSString(string: key)),
            !cache.expiry.isExpired,
            let data = cache.object as? Data else {
                return Fail(error: .isMissing).eraseToAnyPublisher()
        }
        return Just(data).setFailureType(to: DogImageDataCacheError.self).eraseToAnyPublisher()
    }

    func purgeExpired() {
        keys.forEach { key in
            let nsStringKey = NSString(string: key)
            if cache.object(forKey: nsStringKey)?.expiry.isExpired ?? false {
                cache.removeObject(forKey: nsStringKey)
                keys.remove(key)
            }
        }
    }

    func purge() {
        cache.removeAllObjects()
        keys.removeAll()
    }

    struct Config {
        let expiry: Expiry
        let countLimit: UInt
        let totalCostLimit: UInt
        init(expiry: Expiry = .never, countLimit: UInt = 0, totalCostLimit: UInt = 0) {
            self.expiry = expiry
            self.countLimit = countLimit
            self.totalCostLimit = totalCostLimit
        }
    }
}

fileprivate class CacheObject: NSObject {
    let object: Any
    let expiry: Expiry

    init(value: Any, expiry: Expiry) {
        self.object = value
        self.expiry = expiry
    }
}

enum Expiry {
    case never
    case seconds(TimeInterval)
    case date(Date)

    var date: Date {
        switch self {
        case .never:
            // Ref: http://lists.apple.com/archives/cocoa-dev/2005/Apr/msg01833.html
            // last of unix time: 2038-01-19 03:14:07 +0000
            return Date(timeIntervalSince1970: 60*60*24*365*68)
        case .seconds(let seconds):
            return Date().addingTimeInterval(seconds)
        case .date(let date):
            return date
        }
    }

    var isExpired: Bool {
        date.timeIntervalSinceNow < 0
    }
}
