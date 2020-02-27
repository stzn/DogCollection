//
//  BreedListView.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct BreedListView: View {
    @State private var viewState: BreedListViewState = BreedListViewState()
    @Environment(\.injected) var container: DIContainer

    var body: some View {
        NavigationView {
            self.content
                .navigationBarTitle("Search Dogs")
                .edgesIgnoringSafeArea(.bottom)
        }
    }

    private var content: some View {
        switch viewState.filtered {
        case .notRequested:
            return AnyView(notRequestedView)
        case .isLoading:
            return AnyView(LoadingView())
        case .loaded(let breeds):
            return AnyView(loadedView(breeds))
        case .failed(let error):
            return AnyView(errorView(error))
        }
    }

    private var notRequestedView: some View {
        Text("").onAppear { self.loadBreeds() }
    }

    private func loadedView(_ breeds: [Breed]) -> some View {
        VStack {
            SearchBar(text: $viewState.searchText)
            BreedListResultView(breeds: breeds)
            Spacer()
        }
    }

    private func errorView(_ error: Error) -> some View {
        ErrorView(message: error.localizedDescription,
                  retryAction: { self.loadBreeds() })
    }
}

private extension BreedListView {
    func loadBreeds() {
        container.interactors.breedListInteractor.load(breedList: $viewState.all)
    }
}

struct BreedListView_Previews: PreviewProvider {
    static var previews: some View {
        BreedListView()
    }
}
