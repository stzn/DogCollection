//
//  Dog.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

protocol BreedListLoader {
    func load() -> AnyPublisher<[Breed], Error>
}

protocol DogImageListLoader {
    func load(breed: String) -> AnyPublisher<[DogImage], Error>
}

final class DogWebAPI: ObservableObject {
    private let base = URL(string: "https://dog.ceo/api")!
    private let client: WebAPIClient
    init(client: WebAPIClient) {
        self.client = client
    }
}

extension DogWebAPI {
    func run<M: Decodable>(_ type: M.Type, _ request: URLRequest) -> AnyPublisher<M, Error> {
        client.send(request: request)
            .map(\.data)
            .decode(type: M.self, decoder: JSONDecoder())
            .mapError { error in
                if let error = error as? DecodingError {
                    return WebAPIError.decodingError(error)
                }
                return  error
        }
        .eraseToAnyPublisher()
    }
}

extension DogWebAPI: BreedListLoader {
    struct BreedListAPIModel: Decodable {
        let message: [String: [String]]
        let status: String
    }

    func load() -> AnyPublisher<[Breed], Error> {
        run(BreedListAPIModel.self, URLRequest(url: base.appendingPathComponent("breeds/list/all")))
            .map { $0.message.keys.map(Breed.init) }
            .eraseToAnyPublisher()
    }
}

extension DogWebAPI: DogImageListLoader {
    struct DogImageListAPIModel: Decodable {
        let message: [String]
        let status: String
    }

    func load(breed: String) -> AnyPublisher<[DogImage], Error> {
        run(DogImageListAPIModel.self, URLRequest(url: base.appendingPathComponent("/breed/\(breed)/images")))
            .map(convert(from:))
            .eraseToAnyPublisher()
    }

    private func convert(from model: DogImageListAPIModel) -> [DogImage] {
        let urlStrings = model.message
        let dogImages = urlStrings.compactMap { urlString -> DogImage? in
            guard let url = URL(string: urlString) else {
                return nil
            }
            return DogImage(imageURL: url)
        }
        return dogImages
    }
}
