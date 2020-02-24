//
//  APIClient.swift
//  Networking
//
//  Created by Shinzan Takata on 2020/02/01.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

enum APIError : Error {
    case unhandledResponse
    case invalidResponse(URLResponse?)
    case requestError(Int)
    case serverError(Int)
    case decodingError(DecodingError)
    case unknown(Error)

}

extension APIError {
    static func error(from response: HTTPURLResponse) -> APIError? {
        switch response.statusCode {
        case 200...299:
            return nil
        case 400...499:
            return .requestError(response.statusCode)
        case 500...599:
            return .serverError(response.statusCode)
        default:
            return .unhandledResponse
        }
    }
}

struct Response {
    let data: Data
    let response: HTTPURLResponse
}

protocol APIClient {
    func send(request: URLRequest) -> AnyPublisher<Response, APIError>
}
