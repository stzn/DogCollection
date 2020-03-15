//
//  FavoriteDogImageListView.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/03/14.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct FavoriteDogImageListView: View {
    @Environment(\.injected) var container: DIContainer
    @State var viewModel = FavoriteDogImageListViewState()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                self.content
                Spacer()
            }
            .navigationBarTitle("Favorite")
            .onDisappear {
                self.$viewModel.dogImages.wrappedValue = .notRequested
            }
        }
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
        FavoriteDogImageCollection(dogImages: $viewModel.dogImages)
    }

    private func errorView(_ error: Error) -> some View {
        ErrorView(message: error.localizedDescription,
                  retryAction: { self.loadDogImages() })
    }

    private func loadDogImages() {
        container.interactors.favoriteDogImageListInteractor.load(dogImages: $viewModel.dogImages)
    }
}

struct FavoriteDogImageListView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteDogImageListView()
    }
}
