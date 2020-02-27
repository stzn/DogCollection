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
}

final class LiveDogImageListInteractor: DogImageListInteractor {
    let webAPI: DogImageListLoader
    init(webAPI: DogImageListLoader) {
        self.webAPI = webAPI
    }

    func loadDogImages(of breed: String, dogImages: Binding<Loadable<[DogImage]>>) {
        let cancelBag = CancelBag()
        dogImages.wrappedValue = .isLoading(last: dogImages.wrappedValue.value, cancelBag: cancelBag)
        webAPI.loadDogImages(of: breed)
            .receive(on: DispatchQueue.main)
            .sinkToLoadable { dogImages.wrappedValue = $0 }
            .store(in: cancelBag)
    }
}

final class StubDogImageListInteractor: DogImageListInteractor {
    func loadDogImages(of breed: String, dogImages: Binding<Loadable<[DogImage]>>) {}
}
