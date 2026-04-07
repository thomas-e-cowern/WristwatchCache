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
    
    @State private var search = WatchSearchObservable()
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(search.filteredResults(from: favoriteWatches)) { watch in
                        NavigationLink {
                            WatchDetailView(watch: watch)
                        } label: {
                            WatchRowView(watch: watch)
                        }
                    }
                }
                .overlay {
                    VStack {
                        if favoriteWatches.isEmpty {
                            ContentUnavailableView {
                                Label("No watches in your collection", systemImage: "watch.analog")
                            } description: {
                                Text("You haven't addad any watches yet, and there's nothing to favor.  Please click above to add one")
                            }
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
        .searchable(text: $search.searchText)
    }
}

#Preview {
    let preview = PreviewContainer(Watch.self)
    preview.addSamples(Watch.sampleData)
    return WatchFavoritesView()
        .modelContainer(preview.container)
}
