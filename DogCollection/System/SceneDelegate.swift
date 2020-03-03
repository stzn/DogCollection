//
//  SceneDelegate.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var systemEventsHandler: SystemEventsHandler?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let environment = AppEnvironment.bootstrap()
        let contentView = ContentView(container: environment.container)

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()

            self.systemEventsHandler = environment.systemEventsHandler
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        systemEventsHandler?.sceneDidBecomeActive()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        systemEventsHandler?.sceneWillResignActive()
    }
}

