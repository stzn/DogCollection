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
            if !self.breeds.isEmpty {
                List {
                    ForEach(self.breeds) { breed in
                        NavigationLink(destination: DogImageListView(
                            viewModel: DogImageListViewModel(breed: breed.name))) {
                                BreedRow(breed: breed)
                        }
                    }
                }
            } else {
                VStack(alignment: .center) {
                    Spacer().frame(height: 20)
                    HStack {
                        Text("No Results")
                        Image(systemName: "exclamationmark.triangle")
                    }.font(.headline).frame(width: geometry.size.width)
                }
            }
        }
    }
}

struct BreedListSearchResultView_Previews: PreviewProvider {
    static var previews: some View {
        BreedListResultView(
            breeds: [Breed.anyBreed, Breed.anyBreed])
    }
}
