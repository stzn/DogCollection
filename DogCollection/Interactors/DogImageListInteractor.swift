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
    func loadDogImages(of breedType: BreedType, dogImages: Binding<Loadable<[DogImage]>>)
    func addFavoriteDogImage(_ url: URL, of breed: BreedType, dogImages: Binding<Loadable<[DogImage]>>)
    func removeFavoriteDogImage(_ url: URL, of breed: BreedType, dogImages: Binding<Loadable<[DogImage]>>)
}

struct LiveDogImageListInteractor: DogImageListInteractor {
    let loader: DogImageListLoader
    let favoriteDogImageStore: FavoriteDogImageURLsStore
    init(loader: DogImageListLoader, favoriteDogImageStore: FavoriteDogImageURLsStore) {
        self.loader = loader
        self.favoriteDogImageStore = favoriteDogImageStore
    }
    
    func loadDogImages(of breed: BreedType, dogImages: Binding<Loadable<[DogImage]>>) {
        let cancelBag = CancelBag()
        dogImages.wrappedValue = .isLoading(last: dogImages.wrappedValue.value, cancelBag: cancelBag)
        
        Publishers.Zip(favoriteDogImageStore.load(of: breed),
                       loader.load(of: breed))
            .receive(on: DispatchQueue.main)
            .sinkToLoadable { loadable in
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

    func addFavoriteDogImage(_ url: URL, of breed: BreedType, dogImages: Binding<Loadable<[DogImage]>>) {
        guard var dogs = dogImages.wrappedValue.value,
            let index = dogs.firstIndex(where: { $0.imageURL == url }) else {
                return
        }
        let cancelBag = CancelBag()
        favoriteDogImageStore.register(url: url, of: breed)
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

    func removeFavoriteDogImage(_ url: URL, of breed: BreedType, dogImages: Binding<Loadable<[DogImage]>>) {
        guard var dogs = dogImages.wrappedValue.value,
            let index = dogs.firstIndex(where: { $0.imageURL == url }) else {
                return
        }
        let cancelBag = CancelBag()
        favoriteDogImageStore.unregister(url: url, of: breed)
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

struct StubDogImageListInteractor: DogImageListInteractor {
    func addFavoriteDogImage(_ url: URL, of breed: BreedType, dogImages: Binding<Loadable<[DogImage]>>) {}
    func loadDogImages(of breed: BreedType, dogImages: Binding<Loadable<[DogImage]>>) {}
    func removeFavoriteDogImage(_ url: URL, of breed: BreedType, dogImages: Binding<Loadable<[DogImage]>>) {}
}
