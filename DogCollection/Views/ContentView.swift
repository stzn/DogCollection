//
//  ContentView.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/27.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    private let container: DIContainer
    init(container: DIContainer) {
        self.container = container
    }

    var body: some View {
        TabView {
            BreedListView()
                .environment(\.injected, container)
                .tabItem { Text("Search") }
            FavoriteDogImageListView()
                .environment(\.injected, container)
                .tabItem { Text("Favorite") }
        }.font(.headline)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(container: .defaultValue)
    }
}
