//
//  SearchBar.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct SearchBar: UIViewRepresentable {
    enum Status {
        case notSearching
        case searching
    }

    @Binding var text: String
    @Binding var isEditing: Bool
    let showsCancelButton: Bool
    let statusChanged: (Status) -> Void

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        let statusChanged: (Status) -> Void

        init(text: Binding<String>, statusChanged: @escaping (Status) -> Void) {
            _text = text
            self.statusChanged = statusChanged
        }

        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            statusChanged(.searching)
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            statusChanged(.notSearching)
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            text = ""
            searchBar.resignFirstResponder()
            statusChanged(.notSearching)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, statusChanged: statusChanged)
    }

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.autocapitalizationType = .none
        searchBar.backgroundImage = UIImage()
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
        uiView.showsCancelButton = self.showsCancelButton
        if isEditing && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        } else if !isEditing && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant(""), isEditing: .constant(false), showsCancelButton: false, statusChanged: { _ in })
            .previewLayout(.sizeThatFits)
    }
}
