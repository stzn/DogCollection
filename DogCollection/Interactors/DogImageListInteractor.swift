//
//  DogImageListLoader.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/27.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

protocol DogImageListInteractor {
    func loadDogImages(of breed: String, dogImages: Binding<Loadable<[DogImage]>>)
    func addFavoriteDogImage(for url: URL, dogImages: Binding<Loadable<[DogImage]>>)
    func removeFavoriteDogImage(for url: URL, dogImages: Binding<Loadable<[DogImage]>>)
}

final class LiveDogImageListInteractor: DogImageListInteractor {
    let webAPI: DogImageListLoader
    let favoriteDogImageStore: FavoriteDogImageStore
    init(webAPI: DogImageListLoader, favoriteDogImageStore: FavoriteDogImageStore) {
        self.webAPI = webAPI
        self.favoriteDogImageStore = favoriteDogImageStore
    }
    
    func loadDogImages(of breed: String, dogImages: Binding<Loadable<[DogImage]>>) {
        let cancelBag = CancelBag()
        dogImages.wrappedValue = .isLoading(last: dogImages.wrappedValue.value, cancelBag: cancelBag)
        
        Publishers.Zip(favoriteDogImageStore.load(of: breed),
                       webAPI.loadDogImages(of: breed))
            .receive(on: DispatchQueue.main)
            .sinkToLoadable { [weak self] loadable in
                guard let self = self else {
                    return
                }
                dogImages.wrappedValue = loadable.map(self.convertToFavoriteDogImage(favoriteURLs:dogImages:))
        } .store(in: cancelBag)
    }
    
    private func convertToFavoriteDogImage(favoriteURLs: Set<URL>, dogImages: [DogImage]) -> [DogImage] {
        dogImages.map { dogImage in
            if favoriteURLs.contains(dogImage.imageURL) {
                return DogImage(imageURL: dogImage.imageURL, isFavorite: true)
            }
            return dogImage
        }
    }

    func addFavoriteDogImage(for url: URL, dogImages: Binding<Loadable<[DogImage]>>) {
        guard var dogs = dogImages.wrappedValue.value,
            let index = dogs.firstIndex(where: { $0.imageURL == url }) else {
                return
        }
        let cancelBag = CancelBag()
        dogImages.wrappedValue = .isLoading(last: dogs, cancelBag: cancelBag)
        favoriteDogImageStore.register(for: url)
            .sinkToResult { result in
                switch result {
                case .success:
                    dogs[index] = DogImage(imageURL: url, isFavorite: true)
                    dogImages.wrappedValue = .loaded(dogs)
                case .failure:
                    // TODO: エラーハンドリング
                    break
                }
        }.store(in: cancelBag)
    }

    func removeFavoriteDogImage(for url: URL, dogImages: Binding<Loadable<[DogImage]>>) {
        guard var dogs = dogImages.wrappedValue.value,
            let index = dogs.firstIndex(where: { $0.imageURL == url }) else {
                return
        }
        let cancelBag = CancelBag()
        dogImages.wrappedValue = .isLoading(last: dogs, cancelBag: cancelBag)
        favoriteDogImageStore.unregister(for: url)
            .sinkToResult { result in
                switch result {
                case .success:
                    dogs[index] = DogImage(imageURL: url, isFavorite: false)
                    dogImages.wrappedValue = .loaded(dogs)
                case .failure:
                    // TODO: エラーハンドリング
                    break
                }
        }.store(in: cancelBag)
    }
}

final class StubDogImageListInteractor: DogImageListInteractor {
    func addFavoriteDogImage(for url: URL, dogImages: Binding<Loadable<[DogImage]>>) {
    }

    func removeFavoriteDogImage(for url: URL, dogImages: Binding<Loadable<[DogImage]>>) {
    }

    func loadDogImages(of breed: String, dogImages: Binding<Loadable<[DogImage]>>) {}
}
