//
//  WatchFavoritesView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 3/31/26.
//

import SwiftUI
import SwiftData

struct WatchFavoritesView: View {
    @Environment(\.modelContext) var modelContext
    
    @Query(filter: #Predicate<Watch> { watch in
            watch.favorite == true
    }, sort: \.brand) private var favoriteWatches: [Watch]
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(favoriteWatches) { watch in
                        NavigationLink {
                            WatchDetailView(watch: watch)
                        } label: {
                            WatchRowView(watch: watch)
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    AddWatchButton()
                }
            }
        }
    }
}

#Preview {
    let preview = PreviewContainer(Watch.self)
    preview.addSamples(Watch.sampleData)
    return WatchFavoritesView()
        .modelContainer(preview.container)
}
