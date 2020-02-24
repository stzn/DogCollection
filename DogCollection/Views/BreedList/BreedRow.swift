//
//  BreedRow.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct BreedRow: View {
    let breed: Breed
    var body: some View {
        HStack {
            Text(self.breed.name).font(.headline)
        }
    }
}

struct BreedRow_Previews: PreviewProvider {
    static var previews: some View {
        BreedRow(breed: Breed.anyBreed)
    }
}
