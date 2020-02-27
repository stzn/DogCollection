//
//  ImageDataInteractor.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/26.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

protocol ImageDataInteractor {
    func load(from url: URL, image: Binding<Loadable<Data>>)
}

struct LiveImageDataInteractor: ImageDataInteractor {
    let webAPI: ImageWebAPI
    func load(from url: URL, image: Binding<Loadable<Data>>) {
        let cancelBag = CancelBag()
        image.wrappedValue = .isLoading(last: image.wrappedValue.value, cancelBag: cancelBag)
        webAPI.load(from: url)
            .receive(on: DispatchQueue.main)
            .sinkToLoadable { image.wrappedValue = $0 }
            .store(in: cancelBag)
    }
}

struct StubImageDataInteractor: ImageDataInteractor {
    func load(from url: URL, image: Binding<Loadable<Data>>) {}
}