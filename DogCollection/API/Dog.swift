//
//  Dog.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

protocol BreedListGettable {
    func get() -> AnyPublisher<[Breed], Error>
}

protocol DogImageListGettable {
    func get(breed: String) -> AnyPublisher<[DogImage], Error>
}

protocol DogImageDataDownloadable {
    func download(from url: URL) -> AnyPublisher<Data, Error>
}

final class DogAPI: ObservableObject {
    private let base = URL(string: "https://dog.ceo/api")!
    private let client: APIClient
    init(client: APIClient) {
        self.client = client
    }
}

extension DogAPI {
    func run<M: Model>(_ type: M.Type, _ request: URLRequest) -> AnyPublisher<M, Error> {
        client.send(request: request)
            .tryMap { response in
                do {
                    return try M.decoder.decode(M.self, from: response.data)
                } catch let error as DecodingError {
                    throw APIError.decodingError(error)
                } catch {
                    throw APIError.unknown(error)
                }
        }
            .eraseToAnyPublisher()
    }
}

extension DogAPI: BreedListGettable {
    struct BreedListAPIModel: Model {
        let message: [String: [String]]
        let status: String
    }

    func get() -> AnyPublisher<[Breed], Error> {
        run(BreedListAPIModel.self, URLRequest(url: base.appendingPathComponent("breeds/list/all")))
            .map { $0.message.keys.map(Breed.init) }
            .eraseToAnyPublisher()
    }
}

extension DogAPI: DogImageListGettable {
    struct DogImageListAPIModel: Model {
        let message: [String]
        let status: String
    }

    func get(breed: String) -> AnyPublisher<[DogImage], Error> {
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

extension DogAPI: DogImageDataDownloadable {
    func download(from url: URL) -> AnyPublisher<Data, Error> {
        client.send(request: URLRequest(url: url))
            .map { $0.data }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
