//
//  WristStatsView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 4/1/26.
//

import SwiftUI
import SwiftData

struct WristStatsView: View {
    @Query(sort: \Watch.brand) private var watches: [Watch]

    private var stats: WatchStatistics {
        WatchStatistics(watches: watches)
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

                // Watches by brand
                Section("Brands I Own") {
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 10) {
                            ForEach(stats.countByBrand, id: \.brand) { entry in
                                BrandStatsView(label: entry.brand, color: BrandView.brandColor(for: entry.brand), number: entry.count)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
                
                // Watches by style
                Section("Styles I Own") {
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 10) {
                            ForEach(stats.countByStyle, id: \.style) { entry in
                                StyleStatsView(label: entry.style.rawValue, color: entry.style.color, number: entry.count)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }

                // Watches by movement
                Section("Movements I Own") {
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 10) {
                            ForEach(stats.countByMovement, id: \.movement) { entry in
                                MovementStatsView(label: entry.movement.rawValue, color: entry.movement.color, number: entry.count)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }

                // Most worn watch
                if let top = stats.mostWorn, WatchStatistics.wearCount(for: top) > 0 {
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
                            Text("\(WatchStatistics.wearCount(for: top))")
                                .font(.title2.bold())
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }

                // Watches worn today
                Section("Worn Today") {
                    let wornToday = watches.filter { stats.wornToday($0) }
                    if wornToday.isEmpty {
                        Text("No watches worn today")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(wornToday) { watch in
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
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.title3)
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
                                    .frame(width: 44)
                                BrandView(brand: watch.brand)
                                VStack(alignment: .leading) {
                                    Text(watch.brand)
                                        .font(.headline)
                                    Text(watch.model)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(WatchStatistics.wearCount(for: watch))")
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
