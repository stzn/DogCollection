//
//  SearchBarTests.swift
//  DogCollectionTests
//
//  Created by Shinzan Takata on 2020/02/24.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI
import XCTest
@testable import DogCollection

class SearchBarTests: XCTestCase {

    func test_searchBarCorrdinator_beginEditing() {
        let expected = "abc"
        let text = Binding(get: { expected }, set: { _ in })
        let sut = SearchBar.Coordinator(text: text)
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = sut
        XCTAssertTrue(sut.searchBarShouldBeginEditing(searchBar))
        XCTAssertTrue(searchBar.showsCancelButton)
        XCTAssertEqual(text.wrappedValue, expected)
    }

    func test_searchBarCorrdinator_endEditing() {
        let expected = "abc"
        let text = Binding(get: { expected }, set: { _ in })
        let sut = SearchBar.Coordinator(text: text)
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = sut
        XCTAssertTrue(sut.searchBarShouldEndEditing(searchBar))
        XCTAssertFalse(searchBar.showsCancelButton)
        XCTAssertEqual(text.wrappedValue, expected)
    }

    func test_searchBarCorrdinator_textDidChange() {
        var _text = "abc"
        let text = Binding<String>(get: { _text }, set: { text in _text = text })
        let sut = SearchBar.Coordinator(text: text)
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = sut
        sut.searchBar(searchBar, textDidChange: "bbb")
        XCTAssertEqual(text.wrappedValue, "bbb")
    }

    func test_searchBarCoordinator_cancelButtonClicked() {
        var _text = "abc"
        let text = Binding<String>(get: { _text }, set: { text in _text = text })
        let sut = SearchBar.Coordinator(text: text)
        let searchBar = UISearchBar(frame: .zero)
        searchBar.text = text.wrappedValue
        searchBar.delegate = sut
        sut.searchBarCancelButtonClicked(searchBar)
        XCTAssertEqual(searchBar.text, "")
        XCTAssertEqual(text.wrappedValue, "")
    }
}
