//
//  AppEnvironment.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/26.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

struct AppEnvironment {
    let container: DIContainer

    static func bootstrap() -> AppEnvironment {
        let appState = Store<AppState>(AppState())
        return AppEnvironment(container: DIContainer(appState: appState, interactors: configureInteractors()))
    }

    private static func configuredURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration)
    }

    private static func configureInteractors() -> DIContainer.Interactors {
        let session = configuredURLSession()
        let client = URLSessionWebAPIClient(session: session)
        let webAPIs = configureWebAPIs(client: client)
        return .init(breedListInteractor: LiveBreedListInteractor(webAPI: webAPIs.dogWebAPI),
                     dogImageListInteractor: LiveDogImageListInteractor(webAPI: webAPIs.dogWebAPI),
                     imageDataInteractor: LiveImageDataInteractor(webAPI: webAPIs.imageWebAPI))
    }

    private static func configureWebAPIs(client: URLSessionWebAPIClient) -> WebAPIContainer {
        let dogWebAPI = DogWebAPI(client: client)
        let imageWebAPI = ImageWebAPI(client: client)
        return .init(dogWebAPI: dogWebAPI, imageWebAPI: imageWebAPI)
    }
}

private extension AppEnvironment {
    struct WebAPIContainer {
        let dogWebAPI: DogWebAPI
        let imageWebAPI: ImageWebAPI
    }
}