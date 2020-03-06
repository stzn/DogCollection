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

final class MockedFavoriteDogImageStore: FavoriteDogImageStore, Mock {
    enum Action: Equatable {
        case loadFavoriteDogImageURLList
        case register(URL)
        case unregister(URL)
    }

    var actions = MockActions<Action>(expected: [])
    var favoriteDogImageURLListResponse: Result<Set<URL>, Error> = .failure(MockError.valueNotSet)

    func load(of breed: String) -> AnyPublisher<Set<URL>, Error> {
        actions.factual.append(.loadFavoriteDogImageURLList)
        return favoriteDogImageURLListResponse.publish()
    }

    func register(for url: URL) -> AnyPublisher<Void, Error> {
        actions.factual.append(.register(url))
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func unregister(for url: URL) -> AnyPublisher<Void, Error> {
        actions.factual.append(.unregister(url))
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
