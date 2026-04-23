//
//  WristStatsView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 4/1/26.
//

import SwiftUI
import SwiftData
import TipKit

struct WristStatsView: View {

    private let wearPatternsTip = WearPatternsTip()
    @Query(sort: \Watch.brand) private var watches: [Watch]

    private var stats: WatchStatistics {
        WatchStatistics(watches: watches)
    }

    var body: some View {
        NavigationStack {
            List {
                // Collection overview
                Section("Collection Overview") {
                    CollectionOverviewView()
                }

                // Watches by brand
                Section("Brands I Own") {
                    if stats.countByBrand.isEmpty {
                        Text("You haven't added any Brands yet.")
                    } else {
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 10) {
                                ForEach(stats.countByBrand, id: \.brand) { entry in
                                    BrandStatsView(label: entry.brand, color: BrandView.brandColor(for: entry.brand), number: entry.count)
                                }
                            }
                        }
                        .scrollIndicators(.hidden)}
                }
                
                // Watches by style
                Section("Styles I Own") {
                    if stats.countByStyle.isEmpty {
                        Text("You haven't added any Styles yet")
                    } else {
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 10) {
                                ForEach(stats.countByStyle, id: \.style) { entry in
                                    StyleStatsView(label: entry.style.rawValue, color: entry.style.color, number: entry.count)
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
                    }
                }

                // Watches by movement
                Section("Movements I Own") {
                    if stats.countByMovement.count < 1 {
                        Text("Please add some watches to see stats")
                    } else {
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 10) {
                                ForEach(stats.countByMovement, id: \.movement) { entry in
                                    MovementStatsView(label: entry.movement.rawValue, color: entry.movement.color, number: entry.count)
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
                    }
                }

                // Most worn watch
                if let top = stats.mostWorn, WatchStatistics.wearCount(for: top) > 0 {
                    Section("Most Worn") {
                        HStack(spacing: 12) {
                            BrandView(brand: top.brand)
                                .accessibilityHidden(true)
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
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(top.brand) \(top.model), worn \(WatchStatistics.wearCount(for: top)) times")
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
                                    .accessibilityHidden(true)
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
                                    .accessibilityHidden(true)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(watch.brand) \(watch.model), worn today")
                        }
                    }
                }
                

                // Wear Patterns
                if stats.totalWears > 0 {
                    Section("Wear Patterns") {
                        TipView(wearPatternsTip, arrowEdge: .top)
                            .listRowInsets(EdgeInsets())

                        // Day-of-week bar chart
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Days You Wear Watches")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            let maxCount = stats.wearsByDayOfWeek.map(\.count).max() ?? 1
                            ForEach(stats.wearsByDayOfWeek, id: \.weekday) { entry in
                                HStack(spacing: 8) {
                                    Text(entry.symbol)
                                        .font(.caption)
                                        .frame(width: 32, alignment: .trailing)
                                        .accessibilityHidden(true)
                                    GeometryReader { geo in
                                        Capsule()
                                            .fill(Color.accentColor.opacity(0.8))
                                            .frame(
                                                width: maxCount > 0
                                                    ? geo.size.width * CGFloat(entry.count) / CGFloat(maxCount)
                                                    : 0
                                            )
                                    }
                                    .frame(height: 14)
                                    .accessibilityHidden(true)
                                    Text("\(entry.count)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(width: 28, alignment: .leading)
                                        .accessibilityHidden(true)
                                }
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel("\(Calendar.current.weekdaySymbols[entry.weekday - 1]): \(entry.count) \(entry.count == 1 ? "wear" : "wears")")
                            }
                        }
                        .padding(.vertical, 4)

                        // Active rotation
                        LabeledContent("Active Rotation (30 days)", value: "\(stats.activeRotationCount) watches")

                        // Current streak
                        if let streak = stats.currentStreak, streak.days > 1 {
                            LabeledContent("Current Streak") {
                                Text("\(streak.watch.brand) \(streak.watch.model) — \(streak.days) days")
                                    .multilineTextAlignment(.trailing)
                            }
                        }

                        // Longest unworn
                        if let unworn = stats.longestUnworn {
                            LabeledContent("Longest Without Wear") {
                                Text("\(unworn.watch.brand) \(unworn.watch.model) — \(unworn.days) days")
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    }

                    // Favorite watch per day
                    if !stats.favoriteWatchByDayOfWeek.isEmpty {
                        Section("Your Go-To Watch by Day") {
                            ForEach(stats.favoriteWatchByDayOfWeek, id: \.symbol) { entry in
                                HStack(spacing: 12) {
                                    Text(entry.symbol)
                                        .font(.headline)
                                        .frame(width: 36)
                                        .accessibilityHidden(true)
                                    BrandView(brand: entry.watch.brand)
                                        .accessibilityHidden(true)
                                    VStack(alignment: .leading) {
                                        Text(entry.watch.brand)
                                            .font(.subheadline)
                                        Text(entry.watch.model)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("\(entry.symbol): \(entry.watch.brand) \(entry.watch.model)")
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
                                    .accessibilityHidden(true)
                                BrandView(brand: watch.brand)
                                    .accessibilityHidden(true)
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
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Ranked \(index + 1): \(watch.brand) \(watch.model), \(WatchStatistics.wearCount(for: watch)) \(WatchStatistics.wearCount(for: watch) == 1 ? "wear" : "wears")")
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
