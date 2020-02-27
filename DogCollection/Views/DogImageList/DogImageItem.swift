//
//  DogImageRow.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/24.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct DogImageItem: View {
    let url: URL

    @Environment(\.injected) var container: DIContainer
    @State var viewModel = DogImageRowViewState()

    let size: CGSize

    var body: some View {
        VStack {
            self.content
        }.onAppear {
            self.loadImage(from: self.url)
        }
    }

    private var content: some View {
        switch viewModel.imageData {
        case .notRequested:
            return AnyView(notRequestedView)
        case .isLoading:
            return AnyView(loadingView)
        case .loaded:
            return AnyView(loadedView)
        case let .failed(error):
            return AnyView(errorView(error))
        }
    }

    private var notRequestedView: some View {
        Text("").onAppear { self.loadImage(from: self.url) }
    }

    private var loadingView: some View {
        LoadingView(message: "")
            .frame(width: size.width, height: size.height, alignment: .center)
    }

    private func errorView(_ error: Error) -> some View {
        ErrorView(message: error.localizedDescription,
                  retryAction: { self.loadImage(from: self.url) })
    }

    private var loadedView: some View {
        if let data = viewModel.imageData.value,
            let image =  UIImage(data: data) {
            return Image(uiImage: image)
                .resizable()
                .frame(width: size.width, height: size.height, alignment: .center)
                .aspectRatio(contentMode: .fill)
                .clipped()
        } else {
            return Image(uiImage: UIImage(systemName: "photo")!)
                .resizable()
                .frame(width: size.width, height: size.height, alignment: .center)
                .aspectRatio(contentMode: .fill)
                .clipped()
        }
    }

    private func loadImage(from url: URL) {
        container.interactors.imageDataInteractor.load(from: url, image: $viewModel.imageData)
    }
}

struct DogImageRow_Previews: PreviewProvider {
    static var previews: some View {
        DogImageItem(url: DogImage.anyDogImage.imageURL, size: CGSize(width: 200, height: 80))
            .previewLayout(.sizeThatFits)
    }
}
