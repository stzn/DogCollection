//
//  BreedListView.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct BreedListView: View {
    @EnvironmentObject var api: DogAPI
    @ObservedObject(initialValue: BreedListViewModel()) var viewModel: BreedListViewModel

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchText)
                self.content
                Spacer()
            }.navigationBarTitle("Search Dogs")
                .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear {
            self.viewModel.onAppear()
        }
    }

    private var content: some View {
        switch viewModel.state {
        case .notRequested:
            return AnyView(Text("").onAppear { self.viewModel.get(api: self.api) })
        case .loading:
            return AnyView(LoadingView())
        case .loaded:
            return AnyView(BreedListResultView(breeds: self.viewModel.breeds))
        case .error:
            return AnyView(ErrorView(message: self.viewModel.error,
                                     retryAction: { self.viewModel.get(api: self.api) }))
        }
    }
}

struct BreedListView_Previews: PreviewProvider {
    static var previews: some View {
        BreedListView()
            .environmentObject(BreedListGettableStub(breeds: [Breed.anyBreed]))
    }
}

import Combine

final class BreedListGettableStub: BreedListGettable, ObservableObject {
    let breeds: [Breed]
    init(breeds: [Breed]) {
        self.breeds = breeds
    }
    func get() -> AnyPublisher<[Breed], Error> {
        Just(breeds)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
