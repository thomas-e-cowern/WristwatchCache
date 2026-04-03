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
    
    @State private var showAddWatch = false
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(watches) { watch in
                        NavigationLink {
                            WatchDetailView(watch: watch)
                        } label: {
                            WatchRowView(watch: watch)
                        }
                    }
                }
                .sheet(isPresented: $showAddWatch) {
                    AddWatchView()
                }
                .overlay {
                    VStack {
                        if watches.isEmpty {
                            ContentUnavailableView {
                                Label("No watches in your collection", systemImage: "watch.analog")
                            } description: {
                                Text("You haven't addad any watches yet.  Please click below to add one")
                            } actions: {
                                AddWatchButton()
                                    .buttonStyle(.borderedProminent)
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
    }
}

#Preview {
    let preview = PreviewContainer(Watch.self)
    preview.addSamples(Watch.sampleData)
    return WatchListView()
        .modelContainer(preview.container)
}
