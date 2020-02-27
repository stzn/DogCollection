//
//  DIContainer.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/26.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import SwiftUI

struct DIContainer: EnvironmentKey {
    let appState: Store<AppState>
    let interactors: Interactors

    static var defaultValue: Self { Self.default }
    private static let `default` = Self(appState: .init(AppState()),
                                        interactors: .stub)
}

extension EnvironmentValues {
    var injected: DIContainer {
        get { self[DIContainer.self] }
        set { self[DIContainer.self] = newValue }
    }
}

extension DIContainer {
    struct Interactors {
        let breedListInteractor: BreedListInteractor
        let dogImageListInteractor: DogImageListInteractor
        let imageDataInteractor: ImageDataInteractor

        static var stub: Self {
            .init(breedListInteractor: StubBreedListInteractor(),
                  dogImageListInteractor: StubDogImageListInteractor(),
                  imageDataInteractor: StubImageDataInteractor())
        }
    }
}

