//
//  DogImageDataProvider.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/03/07.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

final class DogImageDataProvider: ObservableObject {
    @Published var dogImages: [DogImage]
    init(dogImages: [DogImage]) {
        self.dogImages = dogImages
    }
}
