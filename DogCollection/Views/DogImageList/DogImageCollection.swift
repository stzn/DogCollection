//
//  DogImageCollection.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/24.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct DogImageCollection: View {
    @Environment(\.injected) var container: DIContainer
    
    let breed: BreedType
    @Binding var dogImages: Loadable<[DogImage]>
    
    var body: some View {
        self.collectionView
    }

    // TODO: 表示時のアニメーション

    private var collectionView: some View {
        GeometryReader { proxy in
            CollectionView(data: self.dogImages.value ?? [], layout: flowLayout, elementSize: self.size(for: proxy)) {
                DogImageItem(dogImage: $0, size: self.size(for: proxy), showFavorite: $0.isFavorite, onTap: self.toggleFavorite(of:))
            }
        }
    }

    private func size(for proxy: GeometryProxy) -> CGSize {
        let size = proxy.size.width / CGFloat(columnCount(for: proxy.size))
        return CGSize(width: size, height: size)
    }

    private func columnCount(for size: CGSize) -> Int {
        Int(ceil(size.width / 138))
    }

    private func toggleFavorite(of dogImage: DogImage) {
        if !dogImage.isFavorite {
            container.interactors.dogImageListInteractor
                .addFavoriteDogImage(dogImage.imageURL, of: breed, dogImages: $dogImages)
        } else {
            container.interactors.dogImageListInteractor
                .removeFavoriteDogImage(dogImage.imageURL, of: breed, dogImages: $dogImages)
        }
    }
}

private struct RowModel: Identifiable {
    let id: String
    let items: [DogImage]
    init(items: [DogImage]) {
        self.id = UUID().uuidString
        self.items = items
    }
}


struct DogImageCollection_Previews: PreviewProvider {
    static var previews: some View {
        DogImageCollection(breed: "Tom", dogImages: .constant(.loaded([DogImage.anyDogImage])))
    }
}
