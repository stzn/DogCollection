//
//  DogImage.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

struct DogImage: Equatable {
    let imageURL: URL
}

extension DogImage: Identifiable {
    var id: URL { imageURL }
}

#if DEBUG
extension DogImage {
    static var anyDogImage: DogImage {
        DogImage(imageURL: URL(string: "https://www.image.com")!)
    }
}
#endif
