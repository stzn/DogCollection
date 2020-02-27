//
//  BreedListViewModelTests.swift
//  DogCollectionTests
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import XCTest
@testable import DogCollection

class BreedListViewStateTests: XCTestCase {
    var cancellables: Set<AnyCancellable> = []
    
    func test_init_doNothing() {
        let sut = makeSUT()
        XCTAssertEqual(sut.filtered, .notRequested)
        XCTAssertEqual(sut.all, .notRequested)
        XCTAssertEqual(sut.searchText, "")
    }

    func test_searchText_dataFiltered() {
        var sut = makeSUT()
        let filterKeyword = "a"
        let all = [Breed(name: "a"), Breed(name: "b")]
        sut.all = Loadable<[Breed]>.loaded(all)
        XCTAssertEqual(sut.filtered.value, all)

        sut.input(filterKeyword)
        XCTAssertEqual(sut.filtered.value, all.filter { $0.name.starts(with: filterKeyword) })
    }


    func test_searchText_dataNotFiltered_whenSearchTextIsEmpty() {
        var sut = makeSUT()
        let all = [Breed(name: "a"), Breed(name: "b")]
        sut.all = Loadable<[Breed]>.loaded(all)
        XCTAssertEqual(sut.filtered.value, all)
        sut.input("a")
        sut.input("")
        XCTAssertEqual(sut.filtered.value, all)
    }

    private func makeSUT() -> BreedListViewState {
        let sut = BreedListViewState()
        return sut
    }
}

private extension BreedListViewState {
    mutating func input(_ text: String) {
        searchText = text
    }
}
