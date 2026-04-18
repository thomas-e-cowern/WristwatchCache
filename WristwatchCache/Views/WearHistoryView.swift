//
//  WearHistoryView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 4/18/26.
//

import SwiftUI
import SwiftData

struct WearHistoryView: View {
    @Query(sort: \Watch.brand) private var watches: [Watch]

    private static let sectionFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    /// Every wear event paired with its watch, grouped by calendar day (most recent first)
    private var groupedHistory: [(date: Date, entries: [(watch: Watch, time: Date)])] {
        let calendar = Calendar.current

        let all: [(watch: Watch, date: Date)] = watches.flatMap { watch in
            watch.datesWorn.map { (watch: watch, date: $0) }
        }

        let grouped = Dictionary(grouping: all) { calendar.startOfDay(for: $0.date) }

        return grouped
            .map { (date: $0.key, entries: $0.value.map { (watch: $0.watch, time: $0.date) }) }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        List {
            if groupedHistory.isEmpty {
                ContentUnavailableView {
                    Label("No Wear History", systemImage: "calendar.badge.clock")
                } description: {
                    Text("Wear dates will appear here once you start logging watches.")
                }
            } else {
                ForEach(groupedHistory, id: \.date) { group in
                    Section(Self.sectionFormatter.string(from: group.date)) {
                        ForEach(group.entries, id: \.time) { entry in
                            HStack(spacing: 12) {
                                BrandView(brand: entry.watch.brand)
                                VStack(alignment: .leading) {
                                    Text(entry.watch.brand)
                                        .font(.headline)
                                    Text(entry.watch.model)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Wear History")
    }
}

#Preview {
    let preview = PreviewContainer(Watch.self)
    preview.addSamples(Watch.sampleData)
    return NavigationStack {
        WearHistoryView()
    }
    .modelContainer(preview.container)
}
