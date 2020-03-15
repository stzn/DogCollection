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
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(self.dogImages.value?.keys.map { $0 } ?? [], id: \.self) { breed in
                        self.createList(of: breed, proxy: proxy)
                    }
                }
            }
        }
    }

    private let headerSize: CGFloat = 44

    private func height(proxy: GeometryProxy) -> CGFloat {
        guard let dogs = dogImages.value else {
            return .zero
        }
        let elementSize = self.size(for: proxy)
        let typesCount = dogs.count
        let columnCount = self.columnCount(for: proxy.size)
        var rowCount = 0
        for breed in dogs.keys {
            let count = dogs[breed]?.count ?? 0
            let addition = (count % columnCount == 0) ? 0 : 1
            rowCount += Int(floor(Double(count / columnCount))) + addition
        }
        return CGFloat(rowCount) * elementSize.height + CGFloat(typesCount) * headerSize
    }

    private func height(of breed: BreedType, proxy: GeometryProxy) -> CGFloat {
        guard let dogs = dogImages.value?[breed] else {
            return .zero
        }
        let elementSize = self.size(for: proxy)
        let columnCount = self.columnCount(for: proxy.size)
        let elementCount = dogs.count
        let addition = (elementCount % columnCount == 0) ? 0 : 1
        let rowCount = Int(floor(Double(elementCount / columnCount))) + addition
        return CGFloat(rowCount) * elementSize.height + headerSize
    }

    private func createList(of breed: BreedType, proxy: GeometryProxy) -> some View {
        VStack {
            Text(breed)
                .font(.title)
                .frame(height: headerSize)
            List {
                ForEach(self.dataCollection(of: breed, size: proxy.size)) { rowModel in
                    self.createDogImageItems(for: proxy, with: rowModel)
                }
            }
                .onAppear {
                    UITableView.appearance().separatorStyle = .none
            }
        } .frame(height: self.height(of: breed, proxy: proxy))
    }

    private func createDogImageItems(for proxy: GeometryProxy, with rowModel: RowModel) -> some View {
        let size = self.size(for: proxy)
        return HStack(spacing: 0) {
            ForEach(rowModel.items) { image in
                DogImageItem(dogImage: image, size: size, showFavorite: false)
            }
        }.listRowInsets(EdgeInsets())
    }

    private func size(for proxy: GeometryProxy) -> CGSize {
        let size = proxy.size.width / CGFloat(self.columnCount(for: proxy.size))
        return CGSize(width: size, height: size)
    }

    private func columnCount(for size: CGSize) -> Int {
        Int(ceil(size.width / 138))
    }

    private func dataCollection(of breed: BreedType, size: CGSize) -> [RowModel] {
        guard size != .zero else {
            return []
        }

        let strideSize = self.columnCount(for: size)
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
        FavoriteDogImageCollection(
            dogImages: .constant(
                .loaded(["breed":[DogImage.anyDogImage],
                         "breed2":[DogImage.anyDogImage]])))
    }
}
