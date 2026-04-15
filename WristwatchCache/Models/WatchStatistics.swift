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

    /// Watches with `.available` status that haven't been worn in 90+ days
    var notWornIn90Days: [Watch] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -90, to: Date())!
        return watches.filter { watch in
            watch.watchStatus == .available &&
            (watch.datesWorn.isEmpty || (watch.datesWorn.max() ?? .distantPast) < cutoff)
        }
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

    // MARK: - Wear Patterns

    /// All wear dates across every watch, normalized to start-of-day
    private var allWearDays: [Date] {
        watches.flatMap { watch in
            watch.datesWorn.map { Calendar.current.startOfDay(for: $0) }
        }
    }

    /// Wear count per weekday (1 = Sunday … 7 = Saturday)
    var wearsByDayOfWeek: [(weekday: Int, symbol: String, count: Int)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: allWearDays) { calendar.component(.weekday, from: $0) }
        let symbols = calendar.shortWeekdaySymbols
        return (1...7).map { day in
            (weekday: day, symbol: symbols[day - 1], count: Set(grouped[day] ?? []).count)
        }
    }

    /// The watch most frequently worn on each weekday
    var favoriteWatchByDayOfWeek: [(symbol: String, watch: Watch)] {
        let calendar = Calendar.current
        let symbols = calendar.shortWeekdaySymbols
        var results: [(symbol: String, watch: Watch)] = []

        for day in 1...7 {
            var best: Watch?
            var bestCount = 0
            for watch in watches {
                let count = Set(watch.datesWorn
                    .filter { calendar.component(.weekday, from: $0) == day }
                    .map { calendar.startOfDay(for: $0) }
                ).count
                if count > bestCount {
                    bestCount = count
                    best = watch
                }
            }
            if let watch = best {
                results.append((symbol: symbols[day - 1], watch: watch))
            }
        }
        return results
    }

    /// Number of distinct watches worn in the last 30 days
    var activeRotationCount: Int {
        let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        return watches.filter { watch in
            watch.datesWorn.contains { $0 >= cutoff }
        }.count
    }

    /// Current streak: consecutive days ending today (or yesterday) wearing the same watch
    var currentStreak: (watch: Watch, days: Int)? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Find which watch was worn most recently
        guard let latest = watches
            .filter({ !$0.datesWorn.isEmpty })
            .max(by: { ($0.datesWorn.max() ?? .distantPast) < ($1.datesWorn.max() ?? .distantPast) })
        else { return nil }

        let uniqueDays = Set(latest.datesWorn.map { calendar.startOfDay(for: $0) }).sorted(by: >)

        // Streak must include today or yesterday to be "current"
        guard let mostRecent = uniqueDays.first else { return nil }
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        guard mostRecent >= yesterday else { return nil }

        var streak = 1
        for i in 1..<uniqueDays.count {
            let expected = calendar.date(byAdding: .day, value: -i, to: mostRecent)!
            if uniqueDays[i] == expected {
                streak += 1
            } else {
                break
            }
        }
        return (watch: latest, days: streak)
    }

    /// Average days between wears for a specific watch
    static func averageGap(for watch: Watch) -> Double? {
        let uniqueDays = Set(watch.datesWorn.map { Calendar.current.startOfDay(for: $0) }).sorted()
        guard uniqueDays.count >= 2 else { return nil }
        let totalDays = Calendar.current.dateComponents([.day], from: uniqueDays.first!, to: uniqueDays.last!).day!
        return Double(totalDays) / Double(uniqueDays.count - 1)
    }

    /// The available watch that has gone the longest without being worn
    var longestUnworn: (watch: Watch, days: Int)? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return watches
            .filter { $0.watchStatus == .available && !$0.datesWorn.isEmpty }
            .compactMap { watch -> (watch: Watch, days: Int)? in
                guard let lastWorn = watch.datesWorn.max() else { return nil }
                let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastWorn), to: today).day!
                return (watch: watch, days: days)
            }
            .max(by: { $0.days < $1.days })
    }
}
