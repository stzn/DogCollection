//
//  Binding+.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/25.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

extension Binding {
    init(wrappedValue: Value) {
        var value = wrappedValue
        self.init(get: { value }, set: { value = $0 })
    }
}
