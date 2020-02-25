//
//  DogImageListView.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/24.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct DogImageListView: View {
    @EnvironmentObject var api: DogAPI
    @ObservedObject var viewModel: DogImageListViewModel

    var body: some View {
        VStack(spacing: 0) {
            self.content
            Spacer()
        }.onAppear {
            self.viewModel.get(api: self.api)
        }
    }

    private var content: some View {
        switch viewModel.state {
        case .loading:
            return AnyView(LoadingView())
        case .loaded:
            return AnyView(DogImageCollection(breed: viewModel.breed,
                                              dogImages: viewModel.dogImages))
        case .error:
            return AnyView(ErrorView(message: self.viewModel.error,
                                     retryAction: { self.viewModel.get(api: self.api) }))
        }
    }
}

struct DogImageListView_Previews: PreviewProvider {
    static var previews: some View {
        DogImageListView(viewModel: DogImageListViewModel(breed: Breed.anyBreed.name))
    }
}
