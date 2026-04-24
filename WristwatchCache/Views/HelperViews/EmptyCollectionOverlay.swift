//
//  EmptyCollectionOverlay.swift
//  WristwatchCache
//

import SwiftUI

struct EmptyCollectionOverlay: ViewModifier {
    let isEmpty: Bool
    let message: String
    let showAddButton: Bool

    func body(content: Content) -> some View {
        content
            .overlay {
                VStack {
                    if isEmpty {
                        ContentUnavailableView {
                            Label("No watches in your collection", systemImage: "watch.analog")
                        } description: {
                            Text(message)
                        } actions: {
                            if showAddButton {
                                AddWatchButton()
                                    .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                }
            }
    }
}

extension View {
    func emptyCollectionOverlay(
        isEmpty: Bool,
        message: String,
        showAddButton: Bool = false
    ) -> some View {
        modifier(EmptyCollectionOverlay(
            isEmpty: isEmpty,
            message: message,
            showAddButton: showAddButton
        ))
    }
}
