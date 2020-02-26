//
//  Breed.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

struct Breed: Equatable {
    let name: String
}

extension Breed: Identifiable {
    var id: String { name }
}

#if DEBUG
extension Breed {
    static var anyBreed: Breed {
        Breed(name: "test\(UUID().uuidString)")
    }
}
#endif
