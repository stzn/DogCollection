//
//  FavoriteDogImageListInteractor.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/03/11.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

typealias FavoriteDogImages = [BreedType: [DogImage]]

protocol FavoriteDogImageListInteractor {
    func load(dogImages: Binding<Loadable<FavoriteDogImages>>)
}

final class LiveFavoriteDogImageListInteractor: FavoriteDogImageListInteractor {
    let favoriteDogImageStore: FavoriteDogImageURLsStore
    init(favoriteDogImageStore: FavoriteDogImageURLsStore) {
        self.favoriteDogImageStore = favoriteDogImageStore
    }

    func load(dogImages: Binding<Loadable<FavoriteDogImages>>) {
        let cancelBag = CancelBag()
        dogImages.wrappedValue = .isLoading(last: dogImages.wrappedValue.value, cancelBag: cancelBag)
        favoriteDogImageStore.loadAll()
            .sinkToLoadable { loadable in
                dogImages.wrappedValue = loadable
                    .map { urlsPerBreedType in
                        urlsPerBreedType.mapValues { urls in
                            urls.map { DogImage(imageURL: $0, isFavorite: true) }
                        }
                }
        }.store(in: cancelBag)
    }
}

final class StubFavoriteDogImageListInteractor: FavoriteDogImageListInteractor {
    func load(dogImages: Binding<Loadable<FavoriteDogImages>>) {}
}
