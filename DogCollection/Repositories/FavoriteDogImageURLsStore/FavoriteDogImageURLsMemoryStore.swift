//
//  FavoriteDogImageMemoryStore.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/03/09.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

final class FavoriteDogImageURLsMemoryStore: FavoriteDogImageURLsStore {
    private var urlsPerBreedType: [BreedType: Set<URL>] = [:]

    func load(of breed: BreedType) -> AnyPublisher<Set<URL>, Error> {
        guard let urls = urlsPerBreedType[breed] else {
            return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        return Just(urls).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func loadAll() -> AnyPublisher<[BreedType : Set<URL>], Error> {
        return Just(urlsPerBreedType).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func register(url: URL, for breed: BreedType) -> AnyPublisher<Void, Error> {
        urlsPerBreedType[breed, default: []].insert(url)
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func unregister(url: URL, for breed: BreedType) -> AnyPublisher<Void, Error> {
        if var urls = urlsPerBreedType[breed] {
            urls.remove(url)
            urlsPerBreedType[breed] = urls
        }
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
