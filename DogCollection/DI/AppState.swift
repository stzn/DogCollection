//
//  AppState.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/27.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

struct AppState {
    var system = System()
}

extension AppState {
    struct System: Equatable {
        var isActive: Bool = false
    }
}

extension AppState: Equatable {
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        lhs.system == rhs.system
    }
}

#if DEBUG
extension AppState {
    static var preview: AppState {
        var state = AppState()
        state.system.isActive = true
        return state
    }
}
#endif
