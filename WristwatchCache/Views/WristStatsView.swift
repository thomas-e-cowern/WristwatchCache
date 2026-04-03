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

    private var stats: WatchStatistics {
        WatchStatistics(watches: watches)
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
                    LabeledContent("Total Wears Logged", value: "\(stats.totalWears)")
                    LabeledContent("Never Worn", value: "\(stats.neverWorn.count)")
                }

                // Most worn watch
                if let top = stats.mostWorn, top.datesWorn.count > 0 {
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
                    if watches.isEmpty {
                        ContentUnavailableView {
                            Label("No watches in your collection", systemImage: "watch.analog")
                        } description: {
                            Text("You haven't addad any watches yet.  Please click below to add one")
                        } actions: {
                            AddWatchButton()
                                .buttonStyle(.borderedProminent)
                        }
                    } else {
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
                                if stats.wornToday(watch) {
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
                }
                

                // Wear ranking
                Section("Wear Ranking") {
                    if watches.count < 1 {
                        ContentUnavailableView {
                            Label("No watches in your collection", systemImage: "watch.analog")
                        } description: {
                            Text("You haven't addad any watches yet.  Please click below to add one")
                        } actions: {
                            AddWatchButton()
                                .buttonStyle(.borderedProminent)
                        }
                    } else {
                        ForEach(Array(stats.rankedByWear.enumerated()), id: \.element.id) { index, watch in
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
            } // MARK: End of List
            .navigationTitle("Wrist Stats")
        }
    }
}

#Preview {
    let preview = PreviewContainer(Watch.self)
    preview.addSamples(Watch.sampleData)
    return WristStatsView()
        .modelContainer(preview.container)
}
