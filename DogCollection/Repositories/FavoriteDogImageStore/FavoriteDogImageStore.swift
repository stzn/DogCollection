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

final class StubFavoriteDogImageStore: FavoriteDogImageStore {
    func load(of breed: String) -> AnyPublisher<Set<URL>, Error> {
        Just([DogImage.anyDogImage.imageURL]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func register(for url: URL) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func unregister(for url: URL) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
