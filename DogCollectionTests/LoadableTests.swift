//
//  LoadableTests.swift
//  DogCollectionTests
//
//  Created by Shinzan Takata on 2020/02/29.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import XCTest
@testable import DogCollection

class LoadableTests: XCTestCase {
    func test_equality() {
        let values: [Loadable<Int>] = [
            .notRequested,
            .isLoading(last: nil, cancelBag: CancelBag()),
            .isLoading(last: 9, cancelBag: CancelBag()),
            .loaded(5),
            .loaded(6),
            .failed(anyError)
        ]

        values.enumerated().forEach { (index1, value1) in
            values.enumerated().forEach { (index2, value2) in
                if index1 == index2 {
                    XCTAssertEqual(value1, value2)
                } else {
                    XCTAssertNotEqual(value1, value2)
                }
            }
        }
    }

    func test_cancelLoading() {
        let cancelBag1 = CancelBag()
        let cancelBag2 = CancelBag()
        let subject = PassthroughSubject<Int, Never>()

        subject.sink { _ in }.store(in: cancelBag1)
        subject.sink { _ in }.store(in: cancelBag2)

        var sut1 = Loadable<Int>.isLoading(last: nil, cancelBag: cancelBag1)
        XCTAssertEqual(cancelBag1.cancellables.count, 1)
        sut1.cancelLoading()
        XCTAssertEqual(cancelBag1.cancellables.count, 0)

        var sut2 = Loadable<Int>.isLoading(last: 7, cancelBag: cancelBag2)
        XCTAssertEqual(cancelBag2.cancellables.count, 1)
        sut2.cancelLoading()
        XCTAssertEqual(cancelBag2.cancellables.count, 0)
        XCTAssertEqual(sut2.value, 7)
    }

    func test_map() {
        let values: [Loadable<Int>] = [
            .notRequested,
            .isLoading(last: nil, cancelBag: CancelBag()),
            .isLoading(last: 5, cancelBag: CancelBag()),
            .loaded(7),
            .failed(anyError)
        ]
        let expect: [Loadable<String>] = [
            .notRequested,
            .isLoading(last: nil, cancelBag: CancelBag()),
            .isLoading(last: "5", cancelBag: CancelBag()),
            .loaded("7"),
            .failed(anyError)
        ]
        let sut = values.map { value in
            value.map { "\($0)" }
        }
        XCTAssertEqual(sut, expect)
    }

    func test_helperFunctions() {
        let notRequested = Loadable<Int>.notRequested
        let loadingNil = Loadable<Int>.isLoading(last: nil, cancelBag: CancelBag())
        let loadingValue = Loadable<Int>.isLoading(last: 9, cancelBag: CancelBag())
        let loaded = Loadable<Int>.loaded(5)
        let failedErrValue = Loadable<Int>.failed(anyError)
        [notRequested, loadingNil].forEach {
            XCTAssertNil($0.value)
        }
        [loadingValue, loaded].forEach {
            XCTAssertNotNil($0.value)
        }
        [notRequested, loadingNil, loadingValue, loaded].forEach {
            XCTAssertNil($0.error)
        }
        XCTAssertNotNil(failedErrValue.error)
    }

}
