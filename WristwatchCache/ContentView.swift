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
            Tab("On Wrist", systemImage: "watch.analog", value: 0) {
                OnWristView()
            }
            Tab("Watch List", systemImage: "list.dash", value: 1) {
                WatchListView()
            }
            Tab("Favorites List", systemImage: "heart", value: 2) {
                WatchFavoritesView()
            }
            Tab("Wrist Stats", systemImage: "chart.bar", value: 3) {
                WristStatsView()
            }
            Tab("Occasions", systemImage: "star.circle", value: 4) {
                SpecialOccasionsView()
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

