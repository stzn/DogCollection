//
//  TestHelpers.swift
//  DogCollectionTests
//
//  Created by Shinzan Takata on 2020/02/28.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import SwiftUI
import XCTest
@testable import DogCollection

// MARK: - Constants & Variables

let testURL = URL(string: "https://test.com")!
let okResponse = HTTPURLResponse(url: testURL, statusCode: 200, httpVersion: nil, headerFields: nil)!

var anyError: Error {
    NSError(domain: "testError", code: -1, userInfo: nil) as Error
}

func errorResponse(statusCode: Int) -> HTTPURLResponse {
    HTTPURLResponse(url: testURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}

var anyData: Data {
    UIColor.red.image().pngData()!
}

var anyBreedType: BreedType {
    "test \(UUID().uuidString)"
}

var anyKey: URL {
    URL(string: "https://www.\(UUID().uuidString).com")!
}

// MARK: - UI

extension UIColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { rendererContext in
            setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}

// MARK: - Result

extension Result {
    func publish() -> AnyPublisher<Success, Failure> {
        return publisher
            .buffer(size: 1, prefetch: .byRequest, whenFull: .dropOldest)
            .eraseToAnyPublisher()
    }
}

// MARK: - PublisherTestCase

protocol PublisherTestCase: AnyObject {
    var cancellables: Set<AnyCancellable> { get set }
}

extension PublisherTestCase {
    func recordLoadableUpdates<Value>(initialLoadable: Loadable<Value> = .notRequested,
                                      for timeInterval: TimeInterval = 0.5)
        -> (Binding<Loadable<Value>>, AnyPublisher<[Loadable<Value>], Never>) {
            let publisher = CurrentValueSubject<Loadable<Value>, Never>(initialLoadable)
            let binding = Binding(get: { initialLoadable }, set: { publisher.send($0) })
            let updatesPublisher = Future<[Loadable<Value>], Never> { promise in
                var updates: [Loadable<Value>] = []

                publisher
                    .sink { updates.append($0) }
                    .store(in: &self.cancellables)

                DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
                    promise(.success(updates))
                }
            }.eraseToAnyPublisher()

            return (binding, updatesPublisher)
    }
}
