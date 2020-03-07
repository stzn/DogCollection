//
//  DogImageItem.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/03/06.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct DogImageItem: View {
    @Environment(\.injected) var container: DIContainer
    @State var viewModel = DogImageItemViewState()

    let dogImage: DogImage
    let size: CGSize
    let onTap: (DogImage) -> Void

    private let placeholder = Image(uiImage: UIImage(systemName: "photo")!)

    var body: some View {
        self.content
    }

    private var content: some View {
        switch viewModel.imageData {
        case .notRequested:
            return AnyView(notRequestedView)
        case .isLoading:
            return AnyView(isLoadingView)
        case let .loaded(value):
            return loadedView(value)
        case .failed:
            return AnyView(placeholder)
        }
    }

    private var notRequestedView: some View {
        Text("").onAppear { self.loadDogImageData() }
    }

    private var isLoadingView: some View {
        LoadingView(message: "")
            .frame(width: size.width, height: size.height)
    }

    private func loadedView(_ data: Data) -> AnyView {
        if let image =  UIImage(data: data) {
            return AnyView(
                ZStack(alignment: .bottomTrailing) {
                    Image(uiImage: image).resizable()
                        .frame(width: size.width, height: size.height)
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                    if dogImage.isFavorite {
                        FavoriteBadge()
                            .frame(width: size.width / 4, height: size.width / 4)
                    }
                }.onTapGesture {
                    self.onTap(self.dogImage)
            })
        } else {
            return AnyView(placeholder)
        }
    }

    private func errorView(_ error: Error) -> some View {
        ErrorView(message: error.localizedDescription,
                  retryAction: { self.loadDogImageData() })
    }

    private func loadDogImageData() {
        container.interactors.imageDataInteractor.load(from: dogImage.imageURL, image: $viewModel.imageData)
    }
}

struct DogImageItem_Previews: PreviewProvider {
    static var previews: some View {
        DogImageItem(dogImage: DogImage.anyDogImage, size: CGSize(width: 100, height: 100), onTap: { _ in })
    }
}
