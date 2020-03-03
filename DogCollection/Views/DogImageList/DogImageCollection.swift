//
//  DogImageItems.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/24.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct DogImageCollection: View {
    @Environment(\.injected) var container: DIContainer

    let breed: String
    let dogImages: [DogImage]

    var body: some View {
        GeometryReader { geometry in
            List {
                ForEach(self.dataCollection(items: self.dogImages, size: geometry.size)) { rowModel in
                    self.createDogImageItems(for: geometry, with: rowModel)
                }
            }
            .navigationBarTitle(self.breed)
            .edgesIgnoringSafeArea([.bottom])
            .onAppear {
                UITableView.appearance().separatorStyle = .none
            }
        }
    }

    private func createDogImageItems(for geometry: GeometryProxy, with rowModel: RowModel) -> some View {
        HStack(spacing: 0) {
            ForEach(rowModel.items) { image in
                AsyncImage<Image>(url: image.imageURL,
                                  interactor: self.container.interactors.imageDataInteractor,
                                  placeholder: Image(uiImage: UIImage(systemName: "photo")!))
                    .frame(width: self.size(for: geometry).width, height: self.size(for: geometry).height, alignment: .center)
                    .aspectRatio(contentMode: .fill)
                    .clipped()
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

    private func dataCollection(items: [DogImage], size: CGSize) -> [RowModel] {
        guard size != .zero else {
            return []
        }

        let strideSize = columnCount(for: size)

        let rowModels = stride(from: items.startIndex, to: items.endIndex, by: strideSize)
            .map { index -> RowModel in
                let range = index..<min(index + strideSize, items.endIndex)
                let subItems = items[range]
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
        DogImageCollection(breed: "Tom", dogImages: [DogImage.anyDogImage])
    }
}
