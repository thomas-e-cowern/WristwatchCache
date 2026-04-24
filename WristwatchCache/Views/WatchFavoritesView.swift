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

    @Query private var favoriteWatches: [Watch]

    @State private var search = WatchSearchObservable()

    init() {
        _favoriteWatches = Query(FetchDescriptor<Watch>(
            predicate: #Predicate { $0.favorite == true },
            sortBy: [SortDescriptor(\Watch.brand), SortDescriptor(\Watch.model)]
        ))
    }
    
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
                .emptyCollectionOverlay(
                    isEmpty: favoriteWatches.isEmpty,
                    message: "You haven't added any watches yet, and there's nothing to favor. Please click above to add one"
                )
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
