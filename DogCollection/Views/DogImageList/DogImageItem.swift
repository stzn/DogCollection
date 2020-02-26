//
//  DogImageRow.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/24.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct DogImageItem: View {
    @EnvironmentObject var api: ImageWebAPI
    @ObservedObject var viewModel: DogImageRowViewModel

    let size: CGSize

    var body: some View {
        VStack {
            self.content
        }.onAppear {
            self.viewModel.download(api: self.api)
        }
    }

    private var content: some View {
        switch viewModel.state {
        case .loading:
            return AnyView(
                LoadingView(message: "")
                    .frame(width: size.width, height: size.height, alignment: .center)
            )
        case .loaded:
            return AnyView(loadedView)
        case .error:
            return AnyView(Image(uiImage: UIImage(systemName: "photo")!))
        }
    }

    private var loadedView: some View {
        Image(uiImage: viewModel.image)
            .resizable()
            .frame(width: size.width, height: size.height, alignment: .center)
            .aspectRatio(contentMode: .fill)
            .clipped()
    }
}

struct DogImageRow_Previews: PreviewProvider {
    static var previews: some View {
        DogImageItem(
            viewModel: DogImageRowViewModel(url: DogImage.anyDogImage.imageURL), size: CGSize(width: 80, height: 80))
            .previewLayout(.sizeThatFits)
    }
}
