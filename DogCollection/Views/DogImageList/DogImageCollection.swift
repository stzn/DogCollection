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

    // TODO: 更新のたびに画面全体が再レンダリングされる

    private var list: some View {
        GeometryReader { geometry in
            List {
                ForEach(self.dataCollection(size: geometry.size)) { rowModel in
                    self.createDogImageItems(for: geometry, with: rowModel)
                }
            }.id(UUID())// これがないとレイアウトが崩れる
                .onAppear {
                    UITableView.appearance().separatorStyle = .none
            }
        }
    }

    private func createDogImageItems(for geometry: GeometryProxy, with rowModel: RowModel) -> some View {
        let size = self.size(for: geometry)
        return HStack(spacing: 0) {
            ForEach(rowModel.items) { image in
                DogImageItem(dogImage: image, size: size, showFavorite: image.isFavorite, onTap: self.toggleFavorite(of:))
            }
        }.listRowInsets(EdgeInsets())
    }
    
    private func size(for geometry: GeometryProxy) -> CGSize {
        let size = geometry.size.width / CGFloat(columnCount(for: geometry.size))
        return CGSize(width: size, height: size)
    }
    
    private func columnCount(for size: CGSize) -> Int {
        Int(ceil(size.width / 138))
    }
    
    private func dataCollection(size: CGSize) -> [RowModel] {
        guard size != .zero else {
            return []
        }
        
        let strideSize = columnCount(for: size)
        let dogs = dogImages.value ?? []
        let rowModels = stride(from: dogs.startIndex, to: dogs.endIndex, by: strideSize)
            .map { index -> RowModel in
                let range = index..<min(index + strideSize, dogs.endIndex)
                let subItems = dogs[range]
                return RowModel(items: Array(subItems))
        }
        
        return rowModels
    }
    
    private func toggleFavorite(of dogImage: DogImage) {
        if !dogImage.isFavorite {
            container.interactors.dogImageListInteractor
                .addFavoriteDogImage(dogImage.imageURL, for: breed, dogImages: $dogImages)
        } else {
            container.interactors.dogImageListInteractor
                .removeFavoriteDogImage(dogImage.imageURL, for: breed, dogImages: $dogImages)
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
