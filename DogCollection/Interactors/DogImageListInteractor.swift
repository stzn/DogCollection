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
    func addFavoriteDogImage(_ dogImage: Binding<Loadable<DogImage>>)
    func removeFavoriteDogImage(_ dogImage: Binding<Loadable<DogImage>>)
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
    
    func addFavoriteDogImage(_ dogImage: Binding<Loadable<DogImage>>) {
        guard let dogImageModel = dogImage.wrappedValue.value else {
            assertionFailure("DogImage must not be nil")
            return
        }
        let cancelBag = CancelBag()
        dogImage.wrappedValue = .isLoading(last: dogImage.wrappedValue.value, cancelBag: cancelBag)
        favoriteDogImageStore.register(for: dogImageModel.imageURL)
            .sinkToResult { result in
                switch result {
                case .success:
                    dogImage.wrappedValue = .loaded(
                        DogImage(imageURL: dogImageModel.imageURL,
                                 isFavorite: true))
                case .failure(let error):
                    dogImage.wrappedValue = .failed(error)
                }
        }.store(in: cancelBag)
    }
    
    func removeFavoriteDogImage(_ dogImage: Binding<Loadable<DogImage>>) {
        guard let dogImageModel = dogImage.wrappedValue.value else {
            assertionFailure("DogImage must not be nil")
            return
        }
        let cancelBag = CancelBag()
        dogImage.wrappedValue = .isLoading(last: dogImage.wrappedValue.value, cancelBag: cancelBag)
        favoriteDogImageStore.unregister(for: dogImageModel.imageURL)
            .sinkToResult { result in
                switch result {
                case .success:
                    dogImage.wrappedValue = .loaded(
                        DogImage(imageURL: dogImageModel.imageURL,
                                 isFavorite: false))
                case .failure(let error):
                    dogImage.wrappedValue = .failed(error)
                }
        }.store(in: cancelBag)
    }
}

final class StubDogImageListInteractor: DogImageListInteractor {
    func loadDogImages(of breed: String, dogImages: Binding<Loadable<[DogImage]>>) {}
    func addFavoriteDogImage(_ dogImage: Binding<Loadable<DogImage>>) {}
    func removeFavoriteDogImage(_ dogImage: Binding<Loadable<DogImage>>) {}
}
