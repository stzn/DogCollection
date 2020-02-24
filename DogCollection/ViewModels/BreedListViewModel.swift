//
//  BreedListViewModel.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

final class BreedListViewModel: ObservableObject {
    enum State {
        case notRequested
        case loading
        case loaded
        case error
    }

    @Published var searchText: String = "" {
        didSet {
            if !searchText.isEmpty {
                breeds = breeds.filter { $0.name.starts(with: searchText) }
            } else {
                breeds = originalBreeds
            }
        }
    }
    @Published var state: State = .notRequested

    private(set) var breeds: [Breed] = [] {
        didSet { self.state = .loaded }
    }
    private(set) var error: String = "" {
        didSet { self.state = .error }
    }

    private var cancellables: Set<AnyCancellable> = []
    private var originalBreeds: [Breed] = []

    init() {}

    func onAppear() {
        state = .notRequested
    }

    func get(api: BreedListGettable) {
        state = .loading
        api.get()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { result in
                    if case .failure(let error) = result {
                        self.error = error.localizedDescription
                    }
            },
                receiveValue: { breeds in
                    self.originalBreeds = breeds
                    self.breeds = breeds
            }).store(in: &cancellables)
    }
}
