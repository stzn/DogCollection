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

var anyKey: String {
    UUID().uuidString
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