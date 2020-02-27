//
//  BreedListSearchResultView.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct BreedListResultView: View {
    let breeds: [Breed]

    var body: some View {
        GeometryReader { geometry in
            self.content(for: geometry)
        }
    }

    private func content(for geometry: GeometryProxy) -> AnyView {
        if !self.breeds.isEmpty {
            return AnyView(loadedView)
        } else {
            return AnyView(noResultView(for: geometry))
        }
    }

    private var loadedView: some View {
        List {
            ForEach(self.breeds) { breed in
                NavigationLink(destination: self.dogImageListView(with: breed)) {
                    BreedRow(breed: breed)
                }
            }
        }
    }

    private func dogImageListView(with breed: Breed) -> DogImageListView {
        DogImageListView(breed: breed.name)
    }

    private func noResultView(for geometry: GeometryProxy) -> some View {
        VStack(alignment: .center) {
            Spacer().frame(height: 20)
            HStack {
                Text("No Results")
                Image(systemName: "exclamationmark.triangle")
            }.font(.headline).frame(width: geometry.size.width)
        }
    }
}

struct BreedListSearchResultView_Previews: PreviewProvider {
    static var previews: some View {
        BreedListResultView(
            breeds: [Breed.anyBreed, Breed.anyBreed])
    }
}
