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
    
    private static func configuredMemoryCache() -> DogImageDataMemoryCache {
        return DogImageDataMemoryCache()
    }
    
    private static func configureInteractors(cache: DogImageDataCache) -> DIContainer.Interactors {
        let session = configuredURLSession()
        let client = URLSessionHTTPClient(session: session)
        let webComponents = configureWebComponents(client: client)
        let favoriteDogImageStore = FavoriteDogImageURLsMemoryStore()
        let memoryWarning = NotificationCenter.default
            .publisher(for: UIApplication.didReceiveMemoryWarningNotification)
            .map { _ in }
            .eraseToAnyPublisher()
        return .init(breedListInteractor: LiveBreedListInteractor(loader: webComponents.dogWebAPI),
                     dogImageListInteractor: LiveDogImageListInteractor(loader: webComponents.dogWebAPI,
                                                                        favoriteDogImageStore: favoriteDogImageStore),
                     imageDataInteractor: LiveImageDataInteractor(loader: webComponents.imageWebLoader,
                                                                  cache: cache,
                                                                  cachePolicy: ImageDataCachePolicy(expiry: .seconds(10)),
                                                                  memoryWarning: memoryWarning),
                     favoriteDogImageListInteractor: LiveFavoriteDogImageListInteractor(favoriteDogImageStore: favoriteDogImageStore))
    }
    
    private static func configureWebComponents(client: URLSessionHTTPClient) -> WebComponentContainer {
        let dogWebAPI = DogWebAPI(client: client)
        let imageWebLoader = ImageDataWebLoader(client: client)
        return .init(dogWebAPI: dogWebAPI, imageWebLoader: imageWebLoader)
    }
}

private extension AppEnvironment {
    struct WebComponentContainer {
        let dogWebAPI: DogWebAPI
        let imageWebLoader: ImageDataWebLoader
    }
}
