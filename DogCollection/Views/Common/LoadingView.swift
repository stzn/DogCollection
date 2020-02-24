//
//  LoadingView.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        HStack {
            Text("Loading...").font(.body)
            ActivityIndicator(isAnimating: .constant(true), style: .medium)
        }.padding()
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView().previewLayout(.sizeThatFits)
    }
}
