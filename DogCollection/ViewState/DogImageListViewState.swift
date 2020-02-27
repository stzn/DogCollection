//
//  DogImageListViewModel.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/24.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

struct DogImageListViewState {
    var dogImages: Loadable<[DogImage]> = .notRequested
}
