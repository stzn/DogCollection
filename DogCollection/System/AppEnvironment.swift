//
//  AppEnvironment.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/26.
//  Copyright © 2020 shiz. All rights reserved.
//
import UIKit
import Foundation

struct AppEnvironment {
    let container: DIContainer
    let systemEventsHandler: SystemEventsHandler

    static func bootstrap() -> AppEnvironment {
        let appState = Store<AppState>(AppState())
        let memoryCache = configuredMemoryCache()
        return AppEnvironment(
            container: DIContainer(appState: appState,
                                   interactors: configureInteractors(cache: memoryCache)),
            systemEventsHandler: LiveSystemEventsHandler(appState: appState, caches: [memoryCache]))
    }

    private static func configuredURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration)
    }

    private static func configuredMemoryCache(expiry: Expiry = .seconds(60*60*2)) -> ImageDataMemoryCache {
        let config = ImageDataMemoryCache.Config(expiry: expiry)
        return ImageDataMemoryCache(config: config)
    }

    private static func configureInteractors(cache: ImageDataCache) -> DIContainer.Interactors {
        let session = configuredURLSession()
        let client = URLSessionWebAPIClient(session: session)
        let webAPIs = configureWebAPIs(client: client)
        let favoriteDogImageStore = FavoriteDogImageMemoryStore()
        let memoryWarning = NotificationCenter.default
            .publisher(for: UIApplication.didReceiveMemoryWarningNotification)
            .map { _ in }
            .eraseToAnyPublisher()
        return .init(breedListInteractor: LiveBreedListInteractor(webAPI: webAPIs.dogWebAPI),
                     dogImageListInteractor: LiveDogImageListInteractor(webAPI: webAPIs.dogWebAPI,
                                                                        favoriteDogImageStore: favoriteDogImageStore),
                     imageDataInteractor: LiveImageDataInteractor(webAPI: webAPIs.imageWebAPI,
                                                                  cache: cache,
                                                                  memoryWarning: memoryWarning))
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
