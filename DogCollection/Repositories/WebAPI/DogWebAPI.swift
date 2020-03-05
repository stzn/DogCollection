//
//  Dog.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

final class DogWebAPI: WebAPI {
    let baseURL = URL(string: "https://dog.ceo/api")!
    let client: WebAPIClient
    let queue = DispatchQueue(label: "DogWebAPI")
    init(client: WebAPIClient) {
        self.client = client
    }
}

extension DogWebAPI: BreedListLoader {
    struct BreedListAPIModel: Decodable {
        let message: [String: [String]]
        let status: String
    }

    func load() -> AnyPublisher<[Breed], Error> {
        call(BreedListAPIModel.self, URLRequest(url: baseURL.appendingPathComponent("breeds/list/all")))
            .map { $0.message.keys.map(Breed.init) }
            .eraseToAnyPublisher()
    }
}

extension DogWebAPI: DogImageListLoader {
    struct DogImageListAPIModel: Decodable {
        let message: [String]
        let status: String
    }

    func loadDogImages(of breed: String) -> AnyPublisher<[DogImage], Error> {
        call(DogImageListAPIModel.self, URLRequest(url: baseURL.appendingPathComponent("/breed/\(breed)/images")))
            .map(convert(from:))
            .eraseToAnyPublisher()
    }

    private func convert(from model: DogImageListAPIModel) -> [DogImage] {
        let urlStrings = model.message
        let dogImages = urlStrings.compactMap { urlString -> DogImage? in
            guard let url = URL(string: urlString) else {
                return nil
            }
            return DogImage(imageURL: url, isFavorite: false)
        }
        return dogImages
    }
}
