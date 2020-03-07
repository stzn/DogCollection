//
//  DogImageCollection.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/24.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct DogImageCollection: View {
    let breed: String
    let dogImages: [DogImage]
    let onTap: (DogImage) -> Void

    var body: some View {
        GeometryReader { geometry in
            List {
                ForEach(self.dataCollection(size: geometry.size)) { rowModel in
                    self.createDogImageItems(for: geometry, with: rowModel)
                }
            }.id(UUID())// これがないとレイアウトが崩れる
                .navigationBarTitle(self.breed)
                .edgesIgnoringSafeArea([.bottom])
                .onAppear {
                    UITableView.appearance().separatorStyle = .none
            }
        }
    }

    private func createDogImageItems(for geometry: GeometryProxy, with rowModel: RowModel) -> some View {
        let size = self.size(for: geometry)
        return HStack(spacing: 0) {
            ForEach(rowModel.items) { image in
                DogImageItem(dogImage: image, size: size, onTap: self.onTap)
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
        let rowModels = stride(from: dogImages.startIndex, to: dogImages.endIndex, by: strideSize)
            .map { index -> RowModel in
                let range = index..<min(index + strideSize, dogImages.endIndex)
                let subItems = dogImages[range]
                return RowModel(items: Array(subItems))
        }

        return rowModels
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


struct DogImageItems_Previews: PreviewProvider {
    static var previews: some View {
        DogImageCollection(breed: "Tom", dogImages: [DogImage.anyDogImage], onTap: { _ in })
    }
}
