//
//  MockedFavoriteDogImageStore.swift
//  DogCollectionTests
//
//  Created by Shinzan Takata on 2020/03/06.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation
@testable import DogCollection

final class MockedFavoriteDogImageStore: FavoriteDogImageURLsStore, Mock {
    struct StoredData: Equatable {
        let breed: BreedType
        let url: URL
    }

    enum Action: Equatable {
        case loadFavoriteDogImageURLList
        case loadAllFavoriteDogImageURLList
        case register(StoredData)
        case unregister(StoredData)
    }

    var actions = MockActions<Action>(expected: [])
    var favoriteDogImageURLListResponse: Result<Set<URL>, Error> = .failure(MockError.valueNotSet)
    var favoriteAllDogImageURLListResponse: Result<[BreedType: Set<URL>], Error> = .failure(MockError.valueNotSet)

    func load(of breed: BreedType) -> AnyPublisher<Set<URL>, Error> {
        actions.factual.append(.loadFavoriteDogImageURLList)
        return favoriteDogImageURLListResponse.publish()
    }

    func loadAll() -> AnyPublisher<[BreedType : Set<URL>], Error> {
        actions.factual.append(.loadAllFavoriteDogImageURLList)
        return favoriteAllDogImageURLListResponse.publish()
    }

    func register(url: URL, of breed: BreedType) -> AnyPublisher<Void, Error> {
        actions.factual.append(.register(StoredData(breed: breed, url: url)))
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func unregister(url: URL, of breed: BreedType) -> AnyPublisher<Void, Error> {
        actions.factual.append(.unregister(StoredData(breed: breed, url: url)))
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
