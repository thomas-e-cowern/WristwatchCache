//
//  ContentView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 3/30/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext) var modelContext
    
    @State var selection: Int = 0
    
    var body: some View {
        TabView(selection: $selection) {
            Tab("Watch List", systemImage: "list.dash", value: 0) {
                WatchListView()
            }
            Tab("Favorites List", systemImage: "heart", value: 1) {
                WatchFavoritesView()
            }
        }
    }
}

#Preview {
    let preview = PreviewContainer(Watch.self)
    preview.addSamples(Watch.sampleData)
    return ContentView()
        .modelContainer(preview.container)
}

