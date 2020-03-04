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

final class LiveImageDataInteractor: ImageDataInteractor {
    private let webAPI: ImageDataLoader
    private let cache: ImageDataCache
    private var cancellabels: Set<AnyCancellable> = []
    init(webAPI: ImageDataLoader, cache: ImageDataCache,
         memoryWarning: AnyPublisher<Void, Never>) {
        self.webAPI = webAPI
        self.cache = cache
        memoryWarning.sink { [cache] in
            cache.purge()
        }.store(in: &cancellabels)
    }

    func load(from url: URL, image: Binding<Loadable<Data>>) {
        let webAPI = self.webAPI
        let cache = self.cache
        let cancelBag = CancelBag()
        image.wrappedValue = .isLoading(last: image.wrappedValue.value, cancelBag: cancelBag)
        loadFromCache(from: url)
            .catch { _ in
                webAPI.load(from: url)
        }
        .receive(on: DispatchQueue.main)
        .sinkToLoadable { loadable in
            if case .loaded(let data) = loadable {
                cache.cache(data: data, key: url.absoluteString, expiry: nil)
            }
            image.wrappedValue = loadable
        }
        .store(in: cancelBag)
    }

    func loadFromCache(from url: URL) -> AnyPublisher<Data, ImageDataCacheError> {
        cache.cachedImage(for: url.absoluteString)
    }
}

final class StubImageDataInteractor: ImageDataInteractor {
    func load(from url: URL, image: Binding<Loadable<Data>>) {}
}
