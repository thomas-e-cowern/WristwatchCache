//
//  WatchListView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 3/31/26.
//

import SwiftUI
import SwiftData

struct WatchListView: View {
    @Environment(\.modelContext) var modelContext
    
    @Query var watches: [Watch]
    
    @State private var search = WatchSearchObservable()
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(search.filteredResults(from: watches)) { watch in
                        NavigationLink {
                            WatchDetailView(watch: watch)
                        } label: {
                            WatchRowView(watch: watch)
                        }
                    }
                }
                .overlay {
                    VStack {
                        if watches.isEmpty {
                            ContentUnavailableView {
                                Label("No watches in your collection", systemImage: "watch.analog")
                            } description: {
                                Text("You haven't addad any watches yet.  Please click above to add one")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Watch List")
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
    return WatchListView()
        .modelContainer(preview.container)
}
