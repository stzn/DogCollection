//
//  BreedListViewModel.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

struct BreedListViewState {
    private(set) var filtered: Loadable<[Breed]> = .notRequested
    var all: Loadable<[Breed]> = .notRequested {
        didSet { filter() }
    }

    var searchText: String = "" {
        didSet { filter() }
    }

    private mutating func filter() {
        if searchText.isEmpty {
            filtered = all
        } else {
            filtered = all.map { $0.filter { $0.name.starts(with: searchText) } }
        }
    }
}
