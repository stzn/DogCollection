//
//  DogImageListView.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/24.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import SwiftUI

struct DogImageListView: View {
    let breed: String

    @Environment(\.injected) var container: DIContainer
    @State var viewModel = DogImageListViewState()

    var body: some View {
        VStack(spacing: 0) {
            self.content
            Spacer()
        }
        .navigationBarTitle(self.breed)
    }

    private var content: some View {
        switch viewModel.dogImages {
        case .notRequested:
            return AnyView(notRequestedView)
        case .isLoading:
            return AnyView(LoadingView())
        case .loaded:
            return AnyView(loadedView)
        case let .failed(error):
            return AnyView(ErrorView(message: error.localizedDescription,
                                     retryAction: { self.loadDogImages() }))
        }
    }

    private var notRequestedView: some View {
        Text("").onAppear { self.loadDogImages() }
    }

    private var loadedView: some View {
        DogImageCollection(breed: breed, dogImages: $viewModel.dogImages)
    }

    private func errorView(_ error: Error) -> some View {
        ErrorView(message: error.localizedDescription,
                  retryAction: { self.loadDogImages() })
    }

    private func loadDogImages() {
        container.interactors.dogImageListInteractor.loadDogImages(of: breed, dogImages: $viewModel.dogImages)
    }
}

struct DogImageListView_Previews: PreviewProvider {
    static var previews: some View {
        DogImageListView(breed: "test")
    }
}
