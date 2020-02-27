//
//  BreedListLoader.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/27.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

protocol BreedListInteractor {
    func load(breedList: Binding<Loadable<[Breed]>>)
}

final class LiveBreedListInteractor: BreedListInteractor  {
    let webAPI: BreedListLoader
    init(webAPI: BreedListLoader) {
        self.webAPI = webAPI
    }

    func load(breedList: Binding<Loadable<[Breed]>>) {
        let cancelBag = CancelBag()
        breedList.wrappedValue = .isLoading(last: breedList.wrappedValue.value, cancelBag: cancelBag)
        webAPI.load()
            .receive(on: DispatchQueue.main)
            .sinkToLoadable { breedList.wrappedValue = $0 }
            .store(in: cancelBag)
    }
}

final class StubBreedListInteractor: BreedListInteractor {
    func load(breedList: Binding<Loadable<[Breed]>>) {}
}
