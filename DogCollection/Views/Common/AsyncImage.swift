//
//  AsyncImageView.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/03/04.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct AsyncImage<Placeholder: View>: View {
    @State private(set) var imageData: Loadable<Data> = .notRequested
    private let url: URL
    private let placeholder: Placeholder?
    private let interactor: ImageDataInteractor
    private let configuration: (Image) -> Image
    init(url: URL, interactor: ImageDataInteractor,
         placeholder: Placeholder? = nil,
         configuration: @escaping (Image) -> Image = { $0 }) {
        self.url = url
        self.interactor = interactor
        self.placeholder = placeholder
        self.configuration = configuration
    }

    var body: some View {
        content
    }

    private var content: some View {
        switch imageData {
        case .notRequested:
            return AnyView(notRequestedView)
        case .isLoading:
            return AnyView(loadingView)
        case .loaded:
            return loadedView
        case let .failed(error):
            return AnyView(errorView(error))
        }
    }

    private var notRequestedView: some View {
        Text("").onAppear { self.loadImage(from: self.url) }
    }

    private var loadingView: some View {
        LoadingView(message: "")
    }

    private func errorView(_ error: Error) -> some View {
        ErrorView(message: error.localizedDescription,
                  retryAction: { self.loadImage(from: self.url) })
    }

    private var loadedView: AnyView {
        if let data = imageData.value,
            let image =  UIImage(data: data) {
            return AnyView(Image(uiImage: image).resizable())
        } else {
            return AnyView(placeholder)
        }
    }

    private func loadImage(from url: URL) {
        interactor.load(from: url, image: $imageData)
    }
}
