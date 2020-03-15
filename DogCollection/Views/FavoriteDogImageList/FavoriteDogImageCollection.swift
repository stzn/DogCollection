//
//  FavoriteDogImageCollection.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/03/14.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct FavoriteDogImageCollection: View {
    @Environment(\.injected) var container: DIContainer
    @Binding var dogImages: Loadable<FavoriteDogImages>
    
    var body: some View {
        GeometryReader { proxy in
            ForEach(self.dogImages.value?.keys.map { $0 } ?? [], id: \.self) { breed in
                self.createCollectionView(of: breed, proxy: proxy)
            }
        }
    }

    private func createCollectionView(of breed: BreedType, proxy: GeometryProxy) -> some View {
        CollectionView(data: self.dogImages.value?[breed] ?? [], layout: flowLayout, elementSize: self.size(for: proxy)) {
            DogImageItem(dogImage: $0,
                         size: self.size(for: proxy), showFavorite: false)
        }
    }

    private func size(for geometry: GeometryProxy) -> CGSize {
        let size = geometry.size.width / CGFloat(columnCount(for: geometry.size))
        return CGSize(width: size, height: size)
    }

    private func columnCount(for size: CGSize) -> Int {
        Int(ceil(size.width / 138))
    }

    private func dataCollection(for breed: BreedType, size: CGSize) -> [RowModel] {
        guard size != .zero else {
            return []
        }

        let strideSize = columnCount(for: size)
        let dogs = dogImages.value?[breed] ?? []
        let rowModels = stride(from: dogs.startIndex, to: dogs.endIndex, by: strideSize)
            .map { index -> RowModel in
                let range = index..<min(index + strideSize, dogs.endIndex)
                let subItems = dogs[range]
                return RowModel(items: Array(subItems))
        }

        return rowModels
    }

    private struct RowModel: Identifiable {
        let id: String
        let items: [DogImage]
        init(items: [DogImage]) {
            self.id = UUID().uuidString
            self.items = items
        }
    }
}

struct FavoriteDogImageCollection_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteDogImageCollection(dogImages: .constant(.loaded(["breed":[DogImage.anyDogImage]])))
    }
}
