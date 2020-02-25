//
//  DogImageRowViewModel.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/24.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation
import UIKit

final class DogImageRowViewModel: ObservableObject {
    enum State {
        case loading
        case loaded
        case error
    }

    @Published var state: State = .loading

    private let url: URL
    private var cancellable: AnyCancellable?
    private(set) var image: UIImage = UIImage(systemName: "photo")! {
        didSet { self.state = .loaded }
    }

    init(url: URL) {
        self.url = url
    }

    deinit {
        cancellable?.cancel()
    }
    
    func download(api: ImageDataDownloadable) {
        cancellable = api.download(from: url)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { result in
                    if case .failure(let error) = result {
                        print(error)
                        self.state = .error
                    }
            },
                receiveValue: { data in
                    if let image = UIImage(data: data) {
                        self.image = image
                    }
            })
    }
}
