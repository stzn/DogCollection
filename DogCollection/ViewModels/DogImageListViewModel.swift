//
//  DogImageListViewModel.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/24.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

final class DogImageListViewModel: ObservableObject {
    enum State {
        case loading
        case loaded
        case error
    }

    @Published var state: State = .loading

    private(set) var dogImages: [DogImage] = [] {
        didSet { self.state = .loaded }
    }

    private(set) var error: String = "" {
        didSet { self.state = .error }
    }

    let breed: String
    private var cancellables: Set<AnyCancellable> = []

    init(breed: String) {
        self.breed = breed
    }

    func get(api: DogImageListGettable) {
        api.get(breed: breed)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { result in
                    if case .failure(let error) = result {
                        self.error = error.localizedDescription
                    }
            },
                receiveValue: { dogImages in
                    self.dogImages = dogImages
            }).store(in: &cancellables)
    }
}
