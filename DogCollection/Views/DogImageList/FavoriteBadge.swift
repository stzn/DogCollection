//
//  FavoriteBadge.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/03/05.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct FavoriteBadge: View {
    var body: some View {
        let systemName = "heart.fill"
        return Image(systemName: systemName)
            .resizable()
            .foregroundColor(.red)
    }
}

struct FavoriteBadge_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteBadge()
    }
}
