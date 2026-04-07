//
//  WatchStatistics.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 4/1/26.
//

import Foundation

struct WatchStatistics {
    let watches: [Watch]

    /// Number of unique calendar days a watch has been worn
    static func wearCount(for watch: Watch) -> Int {
        let uniqueDays = Set(watch.datesWorn.map { Calendar.current.startOfDay(for: $0) })
        return uniqueDays.count
    }

    var totalWears: Int {
        watches.reduce(0) { $0 + Self.wearCount(for: $1) }
    }

    var mostWorn: Watch? {
        watches.max(by: { Self.wearCount(for: $0) < Self.wearCount(for: $1) })
    }

    var neverWorn: [Watch] {
        watches.filter { $0.datesWorn.isEmpty }
    }

    /// Number of watches grouped by brand, sorted by count descending
    var countByBrand: [(brand: String, count: Int)] {
        Dictionary(grouping: watches, by: \.brand)
            .map { (brand: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    /// Number of watches grouped by style, sorted by count descending
    var countByStyle: [(style: Style, count: Int)] {
        Dictionary(grouping: watches, by: \.style)
            .map { (style: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    /// Number of watches grouped by movement, sorted by count descending
    var countByMovement: [(movement: Movement, count: Int)] {
        Dictionary(grouping: watches, by: \.movement)
            .map { (movement: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    var rankedByWear: [Watch] {
        watches.sorted { Self.wearCount(for: $0) > Self.wearCount(for: $1) }
    }

    func wornToday(_ watch: Watch) -> Bool {
        watch.datesWorn.contains { Calendar.current.isDateInToday($0) }
    }

    /// The most recently selected watch worn today, based on timestamp
    var todaysWatch: Watch? {
        watches
            .filter { wornToday($0) }
            .max(by: { ($0.datesWorn.last ?? .distantPast) < ($1.datesWorn.last ?? .distantPast) })
    }
}
