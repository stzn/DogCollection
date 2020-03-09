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

class URLSessionHTTPClientTests: XCTestCase {
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

    func test_HTTPClientError_unknown() {
        let expected = anyError
        URLProtocolStub.stub(data: nil, response: nil, error: expected)

        assert(error: HTTPClientError.unknown(expected))
    }

    func test_HTTPClientError_httpStatusCode() {
        let testCases: [(line: UInt, response: HTTPURLResponse, error: HTTPClientError)] = [
            (#line, errorResponse(statusCode: 300), HTTPClientError.unhandledResponse),
            (#line, errorResponse(statusCode: 400), HTTPClientError.requestError(400)),
            (#line, errorResponse(statusCode: 500), HTTPClientError.serverError(500)),
        ]

        for testCase in testCases {
            URLProtocolStub.stub(data: Data(), response: testCase.response, error: nil)
            assert(error: testCase.error, line: testCase.line)
        }
    }

    func test_HTTPClientError_invalidResponse() {
        let invalidURLResponse = URLResponse()
        URLProtocolStub.stub(data: Data(), response: invalidURLResponse, error: nil)
        assert(error: HTTPClientError.invalidResponse(invalidURLResponse))
    }

    // MARK: - Helper

    private func makeSUT() -> URLSessionHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        return URLSessionHTTPClient(session: session)
    }

    private var anyURLRequest: URLRequest {
        URLRequest(url: testURL)
    }

    private func assert(error expected: HTTPClientError, file: StaticString = #file, line: UInt = #line) {
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

    private func send() -> (Response?, Subscribers.Completion<HTTPClientError>?) {
        let sut = makeSUT()
        let exp = expectation(description: "wait for send")
        var response: Response?
        var completion: Subscribers.Completion<HTTPClientError>?
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
