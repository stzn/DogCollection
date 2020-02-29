//
//  URLSessionWebAPIClientTests.swift
//  DogCollectionTests
//
//  Created by Shinzan Takata on 2020/02/29.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import XCTest
@testable import DogCollection

class URLSessionWebAPIClientTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        super.tearDown()
        URLProtocolStub.removeStub()
    }

    func test_success() {
        let anyData = Data()
        URLProtocolStub.stub(data: anyData, response: okResponse, error: nil)

        let (res, completion) = send()

        if case .failure(let error) = completion {
            XCTFail("expect success but got \(error)")
            return
        }

        guard let response = res else {
            XCTFail("expect response but got nil")
            return
        }

        XCTAssertEqual(response.data, anyData)
        XCTAssertEqual(response.response.url, okResponse.url)
        XCTAssertEqual(response.response.statusCode, okResponse.statusCode)
    }

    func test_WebAPIError_unknown() {
        let expected = anyError
        URLProtocolStub.stub(data: nil, response: nil, error: expected)

        assert(error: WebAPIError.unknown(expected))
    }

    //    case decodingError(DecodingError)

    func test_WebAPIError_httpStatusCode() {
        let testCases: [(line: UInt, response: HTTPURLResponse, error: WebAPIError)] = [
            (#line, errorResponse(statusCode: 300), WebAPIError.unhandledResponse),
            (#line, errorResponse(statusCode: 400), WebAPIError.requestError(400)),
            (#line, errorResponse(statusCode: 500), WebAPIError.serverError(500)),
        ]

        for testCase in testCases {
            URLProtocolStub.stub(data: Data(), response: testCase.response, error: nil)
            assert(error: testCase.error, line: testCase.line)
        }
    }

    func test_WebAPIError_invalidResponse() {
        let invalidURLResponse = URLResponse()
        URLProtocolStub.stub(data: Data(), response: invalidURLResponse, error: nil)
        assert(error: WebAPIError.invalidResponse(invalidURLResponse))
    }

    // MARK: - Helper

    private func makeSUT() -> URLSessionWebAPIClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        return URLSessionWebAPIClient(session: session)
    }

    private var anyURLRequest: URLRequest {
        URLRequest(url: testURL)
    }

    private func assert(error expected: WebAPIError, file: StaticString = #file, line: UInt = #line) {
        let (response, completion) = send()

        if let response = response {
            XCTFail("expect error but got \(response)")
        }

        guard case .failure(let error) = completion else {
            XCTFail("expect error but got nil")
            return
        }

        XCTAssertEqual(error.localizedDescription,
                       expected.localizedDescription,
                       file: file, line: line)
    }

    private func send() -> (Response?, Subscribers.Completion<WebAPIError>?) {
        let sut = makeSUT()
        let exp = expectation(description: "wait for send")
        var response: Response?
        var completion: Subscribers.Completion<WebAPIError>?
        sut.send(request: anyURLRequest)
            .sink(receiveCompletion: {
                completion = $0
                exp.fulfill()
            }, receiveValue: {
                response = $0
            }).store(in: &cancellables)

        wait(for: [exp], timeout: 1.0)

        return (response, completion)
    }
}
