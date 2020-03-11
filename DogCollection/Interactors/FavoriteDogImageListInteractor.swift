//
//  FavoriteDogImageListInteractor.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/03/11.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

protocol FavoriteDogImageListInteractor {
    func load(dogImages: Binding<Loadable<[BreedType: [DogImage]]>>)
}
