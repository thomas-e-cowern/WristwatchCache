//
//  WristStatsView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 4/1/26.
//

import SwiftUI
import SwiftData

struct WristStatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Watch.brand) private var watches: [Watch]

    private var totalWears: Int {
        watches.reduce(0) { $0 + $1.datesWorn.count }
    }

    private var mostWorn: Watch? {
        watches.max(by: { $0.datesWorn.count < $1.datesWorn.count })
    }

    private var neverWorn: [Watch] {
        watches.filter { $0.datesWorn.isEmpty }
    }

    private var rankedByWear: [Watch] {
        watches.sorted { $0.datesWorn.count > $1.datesWorn.count }
    }

    private func wornToday(_ watch: Watch) -> Bool {
        watch.datesWorn.contains { Calendar.current.isDateInToday($0) }
    }

    private func markWornToday(_ watch: Watch) {
        watch.datesWorn.append(Date())
        try? modelContext.save()
    }

    var body: some View {
        NavigationStack {
            List {
                // Collection overview
                Section("Collection Overview") {
                    LabeledContent("Total Watches", value: "\(watches.count)")
                    LabeledContent("Total Wears Logged", value: "\(totalWears)")
                    LabeledContent("Never Worn", value: "\(neverWorn.count)")
                }

                // Most worn watch
                if let top = mostWorn, top.datesWorn.count > 0 {
                    Section("Most Worn") {
                        HStack(spacing: 12) {
                            BrandView(brand: top.brand)
                            VStack(alignment: .leading) {
                                Text(top.brand)
                                    .font(.headline)
                                Text(top.model)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(top.datesWorn.count)")
                                .font(.title2.bold())
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }

                // Wore today quick log
                Section("Log Today's Wear") {
                    ForEach(watches) { watch in
                        HStack(spacing: 12) {
                            BrandView(brand: watch.brand)
                            VStack(alignment: .leading) {
                                Text(watch.brand)
                                    .font(.headline)
                                Text(watch.model)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if wornToday(watch) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.title3)
                            } else {
                                Button {
                                    markWornToday(watch)
                                } label: {
                                    Text("Wore Today")
                                        .font(.caption)
                                }
                                .buttonStyle(.bordered)
                                .tint(.blue)
                            }
                        }
                    }
                }

                // Wear ranking
                Section("Wear Ranking") {
                    ForEach(Array(rankedByWear.enumerated()), id: \.element.id) { index, watch in
                        HStack(spacing: 12) {
                            Text("#\(index + 1)")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                                .frame(width: 30)
                            BrandView(brand: watch.brand)
                            VStack(alignment: .leading) {
                                Text(watch.brand)
                                    .font(.headline)
                                Text(watch.model)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(watch.datesWorn.count)")
                                .font(.headline)
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }
            }
            .navigationTitle("On Wrist")
        }
    }
}

#Preview {
    let preview = PreviewContainer(Watch.self)
    preview.addSamples(Watch.sampleData)
    return WristStatsView()
        .modelContainer(preview.container)
}
