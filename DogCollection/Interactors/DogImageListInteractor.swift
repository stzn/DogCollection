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

struct LiveDogImageListInteractor: DogImageListInteractor {
    let webAPI: DogWebAPI
    func loadDogImages(of breed: String, dogImages: Binding<Loadable<[DogImage]>>) {
        let cancelBag = CancelBag()
        dogImages.wrappedValue = .isLoading(last: dogImages.wrappedValue.value, cancelBag: cancelBag)
        webAPI.loadDogImages(of: breed)
            .receive(on: DispatchQueue.main)
            .sinkToLoadable { dogImages.wrappedValue = $0 }
            .store(in: cancelBag)
    }
}

struct StubDogImageListInteractor: DogImageListInteractor {
    func loadDogImages(of breed: String, dogImages: Binding<Loadable<[DogImage]>>) {}
}
