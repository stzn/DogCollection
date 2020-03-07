//
//  DogImageItemViewState.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/24.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation
import UIKit

struct DogImageItemViewState {
    var imageData: Loadable<Data> = .notRequested
}
