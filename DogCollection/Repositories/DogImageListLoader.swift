//
//  DogImageListLoader.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/27.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

protocol DogImageListLoader {
    func loadDogImages(of breed: String) -> AnyPublisher<[DogImage], Error>
}
