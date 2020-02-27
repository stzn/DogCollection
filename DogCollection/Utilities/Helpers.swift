//
//  Helpers.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/27.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

typealias Store<State> = CurrentValueSubject<State, Never>

extension Publisher {
    func sinkToResult(_ result: @escaping (Result<Output, Failure>) -> Void) -> AnyCancellable {
        sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                result(.failure(error))
            default:
                break
            }
        }, receiveValue: { value in
            result(.success(value))
        })
    }

    func sinkToLoadable(_ completion: @escaping (Loadable<Output>) -> Void) -> AnyCancellable {
        sink(receiveCompletion: { finished in
            switch finished {
            case .failure(let error):
                completion(.failed(error))
            default:
                break
            }
        }, receiveValue: { value in
            completion(.loaded(value))
        })
    }

}

extension CurrentValueSubject {
    subscript<T>(keyPath: WritableKeyPath<Output, T>) -> T where T: Equatable {
        get { value[keyPath: keyPath] }
        set {
            var value = self.value
            // mutate only when value changed
            if value[keyPath: keyPath] != newValue {
                value[keyPath: keyPath] = newValue
                self.value = value
            }
        }
    }

    func updates<Value>(for keyPath: KeyPath<Output, Value>)
        -> AnyPublisher<Value, Failure> where Value: Equatable {
            // mutate only when value changed
            map(keyPath).removeDuplicates().eraseToAnyPublisher()
    }
}
