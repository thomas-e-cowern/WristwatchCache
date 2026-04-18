//
//  UnwornWatchView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 4/18/26.
//

import SwiftUI
import SwiftData

struct UnwornWatchView: View {
    @Environment(\.modelContext) var modelContext
    
    @Query(sort: \Watch.brand) private var watches: [Watch]

    private var unwornWatches: [Watch] {
        watches.filter { $0.datesWorn.isEmpty }
    }

    var body: some View {
        List {
            ForEach(unwornWatches) { watch in
                WatchRowView(watch: watch)
            }
        }
        .navigationTitle("Unworn Watches")
    }
}

#Preview {
    let preview = PreviewContainer(Watch.self)
    preview.addSamples(Watch.sampleData)
    return UnwornWatchView()
        .modelContainer(preview.container)
}
