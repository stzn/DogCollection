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
    @Published var image: UIImage = UIImage(systemName: "photo")!

    private let url: URL
    private var cancellable: AnyCancellable?

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
                        self.image = UIImage(systemName: "photo")!
                    }
            },
                receiveValue: { data in
                    if let image = UIImage(data: data) {
                        self.image = image
                    }
            })
    }
}
