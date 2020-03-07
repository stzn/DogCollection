//
//  FavoriteDogImage.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/03/06.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

typealias FavoriteDogImageStore = FavoriteDogImageLoader & FavoriteDogImageRegistrator

protocol FavoriteDogImageLoader {
    func load(of breed: String) -> AnyPublisher<Set<URL>, Error>
}

protocol FavoriteDogImageRegistrator {
    func register(for url: URL) -> AnyPublisher<Void, Error>
    func unregister(for url: URL) -> AnyPublisher<Void, Error>
}

final class FavoriteDogImageMemoryStore: FavoriteDogImageStore {
    private var urls: Set<URL> = []
    func load(of breed: String) -> AnyPublisher<Set<URL>, Error> {
        print(urls)
        return Just(urls).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func register(for url: URL) -> AnyPublisher<Void, Error> {
        urls.insert(url)
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func unregister(for url: URL) -> AnyPublisher<Void, Error> {
        urls.remove(url)
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
