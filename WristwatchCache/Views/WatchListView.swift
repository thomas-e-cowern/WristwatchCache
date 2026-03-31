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
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(watches) { watch in
                        NavigationLink {
                            WatchDetailView(watch: watch)
                        } label: {
                            HStack {
                                BrandView(brand: watch.brand)
                                Text(watch.model)
                                    .font(.headline)
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
