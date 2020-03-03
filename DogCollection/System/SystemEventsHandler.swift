//
//  SystemEventsHandler.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/03/01.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

protocol SystemEventsHandler {
    func sceneDidBecomeActive()
    func sceneWillResignActive()
}

struct LiveSystemEventsHandler: SystemEventsHandler {
    let appState: Store<AppState>
    let caches: [ImageDataCache]
    init(appState: Store<AppState>, caches: [ImageDataCache]) {
        self.appState = appState
        self.caches = caches
    }

    func sceneDidBecomeActive() {
        appState[\.system.isActive] = true
        caches.forEach { $0.purgeExpired() }
    }

    func sceneWillResignActive() {
        appState[\.system.isActive] = false
    }
}
