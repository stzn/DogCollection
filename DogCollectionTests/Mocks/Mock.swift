//
//  Mock.swift
//  DogCollectionTests
//
//  Created by Shinzan Takata on 2020/02/28.
//  Copyright © 2020 shiz. All rights reserved.
//

import XCTest
@testable import DogCollection

protocol Mock {
    associatedtype Action: Equatable
    var actions: MockActions<Action> { get }

    func register(_ action: Action)
    func verify(file: StaticString, line: UInt)
}

extension Mock {
    func register(_ action: Action) {
        actions.register(action)
    }

    func verify(file: StaticString = #file, line: UInt = #line) {
        actions.verify(file: file, line: line)
    }
}

final class MockActions<Action> where Action: Equatable {
    let expected: [Action]
    var factual: [Action] = []

    init(expected: [Action]) {
        self.expected = expected
    }

    fileprivate func register(_ action: Action) {
        factual.append(action)
    }

    fileprivate func verify(file: StaticString, line: UInt) {
        if factual == expected {
            return
        }
        let factualNames = factual.map { "." + String(describing: $0) }
        let expectedNames = expected.map { "." + String(describing: $0) }
        XCTFail("\(name)\nExpected:\n\(expectedNames)\nReceived:\n\(factualNames)", file: file, line: line)
    }

    private var name: String {
        let fullName = String(describing: self)
        let nameComponents = fullName.components(separatedBy: ".")
        return nameComponents.dropLast().last ?? fullName
    }
}

// MARK: - Error

enum MockError: Swift.Error {
    case valueNotSet
}
