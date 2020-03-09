//
//  ImageDataInteractor.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/26.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

protocol ImageDataInteractor {
    func load(from url: URL, image: Binding<Loadable<Data>>)
}

struct LiveImageDataInteractor: ImageDataInteractor {
    private let loader: ImageDataLoader
    private let cache: DogImageDataCache
    private let cachePolicy: CachePolicy
    private var cancellabels: Set<AnyCancellable> = []
    init(loader: ImageDataLoader, cache: DogImageDataCache,
         cachePolicy: CachePolicy,
         memoryWarning: AnyPublisher<Void, Never>) {
        self.loader = loader
        self.cache = cache
        self.cachePolicy = cachePolicy
        memoryWarning.sink { [cache] in
            cache.purge()
        }.store(in: &cancellabels)
    }

    func load(from url: URL, image: Binding<Loadable<Data>>) {
        let cancelBag = CancelBag()
        image.wrappedValue = .isLoading(last: image.wrappedValue.value, cancelBag: cancelBag)
        loadFromCache(from: url)
            .catch { _ in
                self.loader.load(from: url)
        }
        .receive(on: DispatchQueue.main)
        .sinkToLoadable { loadable in
            if case .loaded(let data) = loadable {
                self.cache.cache(data, key: url, expiry: self.cachePolicy.expiry)
            }
            image.wrappedValue = loadable
        }
        .store(in: cancelBag)
    }

    func loadFromCache(from url: URL) -> AnyPublisher<Data, CacheError> {
        cache.purgeExpired()
        return cache.cachedImage(for: url)
    }
}

struct StubImageDataInteractor: ImageDataInteractor {
    func load(from url: URL, image: Binding<Loadable<Data>>) {}
}
