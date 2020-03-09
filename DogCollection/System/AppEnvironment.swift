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

    private static func configuredMemoryCache(expiry: Expiry = .seconds(60*60*2)) -> DogImageDataMemoryCache {
        return DogImageDataMemoryCache()
    }

    private static func configureInteractors(cache: DogImageDataCache) -> DIContainer.Interactors {
        let session = configuredURLSession()
        let client = URLSessionHTTPClient(session: session)
        let webAPIs = configureWebAPIs(client: client)
        let favoriteDogImageStore = FavoriteDogImageURLsMemoryStore()
        let memoryWarning = NotificationCenter.default
            .publisher(for: UIApplication.didReceiveMemoryWarningNotification)
            .map { _ in }
            .eraseToAnyPublisher()
        return .init(breedListInteractor: LiveBreedListInteractor(loader: webAPIs.dogWebAPI),
                     dogImageListInteractor: LiveDogImageListInteractor(loader: webAPIs.dogWebAPI,
                                                                        favoriteDogImageStore: favoriteDogImageStore),
                     imageDataInteractor: LiveImageDataInteractor(loader: webAPIs.imageWebAPI,
                                                                  cache: cache,
                                                                  cachePolicy: ImageDataCachePolicy(expiry: .seconds(10)),
                                                                  memoryWarning: memoryWarning))
    }

    private static func configureWebAPIs(client: URLSessionHTTPClient) -> WebAPIContainer {
        let dogWebAPI = DogWebAPI(client: client)
        let imageWebAPI = ImageDataWebAPI(client: client)
        return .init(dogWebAPI: dogWebAPI, imageWebAPI: imageWebAPI)
    }
}

private extension AppEnvironment {
    struct WebAPIContainer {
        let dogWebAPI: DogWebAPI
        let imageWebAPI: ImageDataWebAPI
    }
}
