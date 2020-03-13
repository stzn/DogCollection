//
//  DogWebAPITests.swift
//  DogCollectionTests
//
//  Created by Shinzan Takata on 2020/03/13.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import XCTest
@testable import DogCollection

class DogWebAPITests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    func test_init_doesNotLoad() {
        let (_, client) = makeSUT(with: anyResponse)
        XCTAssertEqual(client.actions.factual.count, 0)
        client.verify()
    }

    func test_loadBreedList_loadData() {
        let expected = [Breed.anyBreed]
        let response = Response(data: makeBreedListJSONData(from: expected), response: okResponse)
        let (sut, client) = makeSUT(with: response)
        client.actions = .init(expected: [.send])

        let exp = expectation(description: "wait for load")
        sut.load().sinkToResult { result in
            defer { exp.fulfill() }
            switch result {
            case .success(let received):
                XCTAssertEqual(expected, received)
            case .failure:
                XCTFail("expect success, but got \(result)")
            }
        }.store(in: &cancellables)

        wait(for: [exp], timeout: 1.0)

        client.verify()
    }

    func test_loadBreedListError_deliverError() {
        let expected = HTTPClientError.requestError(400)
        let (sut, client) = makeSUT(with: expected)
        client.actions = .init(expected: [.send])

        let exp = expectation(description: "wait for load")
        sut.load().sinkToResult { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail("expect failure, but got \(result)")
            case .failure(let received):
                XCTAssertEqual(expected.localizedDescription,
                               received.localizedDescription)
            }
        }.store(in: &cancellables)

        wait(for: [exp], timeout: 1.0)

        client.verify()
    }

    func test_loadDogImageList_loadData() {
        let expected = [DogImage.anyDogImage]
        let response = Response(data: makeDogImageListJSONData(from: expected), response: okResponse)
        let (sut, client) = makeSUT(with: response)
        client.actions = .init(expected: [.send])

        let exp = expectation(description: "wait for load")
        sut.load(of: anyBreedType).sinkToResult { result in
            defer { exp.fulfill() }
            switch result {
            case .success(let received):
                XCTAssertEqual(expected, received)
            case .failure:
                XCTFail("expect success, but got \(result)")
            }
        }.store(in: &cancellables)

        wait(for: [exp], timeout: 1.0)

        client.verify()
    }

    func test_loadDogImageError_deliverError() {
        let expected = HTTPClientError.requestError(400)
        let (sut, client) = makeSUT(with: expected)
        client.actions = .init(expected: [.send])

        let exp = expectation(description: "wait for load")
        sut.load(of: anyBreedType).sinkToResult { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail("expect failure, but got \(result)")
            case .failure(let received):
                XCTAssertEqual(expected.localizedDescription,
                               received.localizedDescription)
            }
        }.store(in: &cancellables)

        wait(for: [exp], timeout: 1.0)

        client.verify()
    }

    // MARK: - Helper
    private func makeSUT(with response: Response) -> (DogWebAPI, MockHTTPClient) {
        let client = MockHTTPClient.output(response: response)
        let sut = DogWebAPI(client: client)
        return (sut, client)
    }

    private func makeSUT(with error: HTTPClientError) -> (DogWebAPI, MockHTTPClient) {
        let client = MockHTTPClient.failure(error: error)
        let sut = DogWebAPI(client: client)
        return (sut, client)
    }

    private var anyResponse: Response {
        Response(data: Data(), response: okResponse)
    }

    private var okResponse: HTTPURLResponse {
        HTTPURLResponse(url: testURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    private func makeBreedListJSONData(from breeds: [Breed],
                                       file: StaticString = #file, line: UInt = #line) -> Data {
        do {
            var dictionary: [String: [String]] = [:]
            breeds.forEach { dictionary[$0.name] = [] }
            let jsonObject: [String: Any] = ["message": dictionary, "status": ""]
            return try JSONSerialization.data(withJSONObject: jsonObject, options: [])
        } catch let error {
            XCTFail("error \(error)")
            fatalError()
        }
    }

    private func makeDogImageListJSONData(from dogImages: [DogImage],
                                          file: StaticString = #file, line: UInt = #line) -> Data {
        do {
            let urls = dogImages.map { $0.imageURL.absoluteString }
            let jsonObject: [String: Any] = ["message": urls, "status": ""]
            return try JSONSerialization.data(withJSONObject: jsonObject, options: [])
        } catch let error {
            XCTFail("error \(error)")
            fatalError()
        }
    }
}
