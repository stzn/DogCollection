//
//  MemoryCache.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/03/09.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

final class MemoryCache<Key: Hashable, Value> {
    private let queue = DispatchQueue(label: "MemoryCache", attributes: .concurrent)
    private var values: [Key: CacheObject<Value>] = [:]

    func insert(_ value: Value, for key: Key, expiry: Expiry) {
        queue.async(flags: .barrier) { [weak self] in
            let cacheObject = CacheObject(value: value, expiry: expiry)
            self?.values[key] = cacheObject
        }
    }

    func value(for key: Key) -> AnyPublisher<Value, CacheError> {
        var value: CacheObject<Value>?
        queue.sync { [weak self] in
            value = self?.values[key]
        }
        guard let cache = value, !cache.isExpired else {
            return Fail(error: .isMissing).eraseToAnyPublisher()
        }
        return Just(cache.object).setFailureType(to: CacheError.self).eraseToAnyPublisher()
    }

    func purgeExpired() {
        queue.async(flags: .barrier) { [weak self] in
            self?.values.forEach { (key, value) in
                if value.isExpired {
                    self?.values[key] = nil
                }
            }
        }
    }

    func purge() {
        queue.async(flags: .barrier) { [weak self] in
            self?.values = [:]
        }
    }
}

fileprivate struct CacheObject<Value> {
    let object: Value
    let expirationDate: Date

    init(value: Value, expiry: Expiry) {
        self.object = value
        self.expirationDate = expiry.date
    }

    var isExpired: Bool {
        return expirationDate.timeIntervalSinceNow < 0
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
}
