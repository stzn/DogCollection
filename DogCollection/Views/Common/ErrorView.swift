//
//  ErrorView.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack {
            HStack {
                Text("Error")
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(Color.orange)
            }.font(.headline)
            Text(message).font(.body)
            Button(action: retryAction, label: { Text("Retry").bold() })
        }.padding()
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(message: "something wrong", retryAction: { })
            .previewLayout(.sizeThatFits)
    }
}
