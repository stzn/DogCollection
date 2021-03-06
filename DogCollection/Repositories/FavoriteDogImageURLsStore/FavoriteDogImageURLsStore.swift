//
//  FavoriteDogImage.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/03/06.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

typealias FavoriteDogImageURLsStore = FavoriteDogImageURLsLoader & FavoriteDogImageURLsRegistrator
typealias BreedType = String

protocol FavoriteDogImageURLsLoader {
    func load(of breed: BreedType) -> AnyPublisher<Set<URL>, Error>
    func loadAll() -> AnyPublisher<[BreedType: Set<URL>], Error>
}

protocol FavoriteDogImageURLsRegistrator {
    func register(url: URL, of breed: BreedType) -> AnyPublisher<Void, Error>
    func unregister(url: URL, of breed: BreedType) -> AnyPublisher<Void, Error>
}
