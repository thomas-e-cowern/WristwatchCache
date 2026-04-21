//
//  WristStatsLogicTests.swift
//  WristwatchCacheTests
//
//  Created by Thomas Cowern on 4/1/26.
//

import Testing
import Foundation
@testable import WristwatchCache

@MainActor
@Suite("Watch Statistics Logic Tests")
struct WristStatsLogicTests {

    private func makeWatch(
        brand: String = "Test",
        model: String = "Watch",
        datesWorn: [Date] = []
    ) -> Watch {
        Watch(
            brand: brand, model: model,
            style: .dress, movement: .automatic,
            hasBracelet: false, watchStatus: .available,
            accuracyMethod: .manual, datesWorn: datesWorn
        )
    }

    /// Helper to create a date N days ago from today
    private func daysAgo(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -n, to: Date())!
    }

    // MARK: - wearCount

    @Test("wearCount returns 0 for empty datesWorn")
    func wearCountEmpty() {
        let watch = makeWatch()
        #expect(WatchStatistics.wearCount(for: watch) == 0)
    }

    @Test("wearCount counts unique calendar days")
    func wearCountUniqueDays() {
        let watch = makeWatch(datesWorn: [daysAgo(1), daysAgo(2), daysAgo(3)])
        #expect(WatchStatistics.wearCount(for: watch) == 3)
    }

    @Test("wearCount deduplicates multiple entries on the same day")
    func wearCountDeduplicates() {
        let today = Date()
        let alsoToday = Date().addingTimeInterval(60)
        let watch = makeWatch(datesWorn: [today, alsoToday, daysAgo(1)])
        #expect(WatchStatistics.wearCount(for: watch) == 2)
    }

    @Test("wearCount returns 1 when all entries are the same day")
    func wearCountAllSameDay() {
        let t1 = Date()
        let t2 = Date().addingTimeInterval(30)
        let t3 = Date().addingTimeInterval(60)
        let watch = makeWatch(datesWorn: [t1, t2, t3])
        #expect(WatchStatistics.wearCount(for: watch) == 1)
    }

    // MARK: - totalWears

    @Test("totalWears returns 0 for empty collection")
    func totalWearsEmpty() {
        let stats = WatchStatistics(watches: [])
        #expect(stats.totalWears == 0)
    }

    @Test("totalWears sums unique wear days across watches")
    func totalWearsSum() {
        let watches = [
            makeWatch(datesWorn: [daysAgo(1), daysAgo(2)]),
            makeWatch(datesWorn: [daysAgo(3)]),
            makeWatch(datesWorn: []),
        ]
        let stats = WatchStatistics(watches: watches)
        #expect(stats.totalWears == 3)
    }

    @Test("totalWears returns 0 when all watches have empty datesWorn")
    func totalWearsAllEmpty() {
        let watches = [makeWatch(), makeWatch(), makeWatch()]
        let stats = WatchStatistics(watches: watches)
        #expect(stats.totalWears == 0)
    }

    @Test("totalWears counts unique days per watch")
    func totalWearsSingle() {
        let watches = [makeWatch(datesWorn: [daysAgo(1), daysAgo(2), daysAgo(3)])]
        let stats = WatchStatistics(watches: watches)
        #expect(stats.totalWears == 3)
    }

    @Test("totalWears deduplicates same-day entries")
    func totalWearsDeduplicates() {
        let today = Date()
        let alsoToday = Date().addingTimeInterval(60)
        let watches = [makeWatch(datesWorn: [today, alsoToday])]
        let stats = WatchStatistics(watches: watches)
        #expect(stats.totalWears == 1)
    }

    // MARK: - mostWorn

    @Test("mostWorn returns nil for empty collection")
    func mostWornEmpty() {
        let stats = WatchStatistics(watches: [])
        #expect(stats.mostWorn == nil)
    }

    @Test("mostWorn returns watch with most unique days worn")
    func mostWornFindsMax() {
        let watches = [
            makeWatch(brand: "One", datesWorn: [daysAgo(1)]),
            makeWatch(brand: "Winner", datesWorn: [daysAgo(1), daysAgo(2), daysAgo(3)]),
            makeWatch(brand: "Two", datesWorn: [daysAgo(1), daysAgo(2)]),
        ]
        let stats = WatchStatistics(watches: watches)
        #expect(stats.mostWorn?.brand == "Winner")
    }

    @Test("mostWorn returns a watch when all have zero wears")
    func mostWornAllZero() {
        let watches = [makeWatch(brand: "A"), makeWatch(brand: "B")]
        let stats = WatchStatistics(watches: watches)
        #expect(stats.mostWorn != nil)
    }

    @Test("mostWorn works with single watch")
    func mostWornSingle() {
        let watch = makeWatch(brand: "Only", datesWorn: [daysAgo(1)])
        let stats = WatchStatistics(watches: [watch])
        #expect(stats.mostWorn?.brand == "Only")
    }

    @Test("mostWorn ignores duplicate same-day entries")
    func mostWornDeduplicates() {
        let today = Date()
        let alsoToday = Date().addingTimeInterval(60)
        let watches = [
            makeWatch(brand: "Inflated", datesWorn: [today, alsoToday, alsoToday]),
            makeWatch(brand: "Real", datesWorn: [daysAgo(1), daysAgo(2)]),
        ]
        let stats = WatchStatistics(watches: watches)
        #expect(stats.mostWorn?.brand == "Real")
    }

    // MARK: - neverWorn

    @Test("neverWorn returns empty when all watches have been worn")
    func neverWornAllWorn() {
        let watches = [
            makeWatch(datesWorn: [daysAgo(1)]),
            makeWatch(datesWorn: [daysAgo(2)]),
        ]
        let stats = WatchStatistics(watches: watches)
        #expect(stats.neverWorn.isEmpty)
    }

    @Test("neverWorn filters watches with empty datesWorn")
    func neverWornFilters() {
        let watches = [
            makeWatch(brand: "Worn", datesWorn: [daysAgo(1)]),
            makeWatch(brand: "Unworn"),
            makeWatch(brand: "AlsoWorn", datesWorn: [daysAgo(2)]),
        ]
        let stats = WatchStatistics(watches: watches)
        #expect(stats.neverWorn.count == 1)
        #expect(stats.neverWorn.first?.brand == "Unworn")
    }

    @Test("neverWorn returns all watches when none have been worn")
    func neverWornAll() {
        let watches = [makeWatch(brand: "A"), makeWatch(brand: "B"), makeWatch(brand: "C")]
        let stats = WatchStatistics(watches: watches)
        #expect(stats.neverWorn.count == 3)
    }

    @Test("neverWorn returns empty for empty collection")
    func neverWornEmpty() {
        let stats = WatchStatistics(watches: [])
        #expect(stats.neverWorn.isEmpty)
    }

    // MARK: - rankedByWear

    @Test("rankedByWear sorts descending by unique wear days")
    func rankedDescending() {
        let watches = [
            makeWatch(brand: "One", datesWorn: [daysAgo(1)]),
            makeWatch(brand: "Three", datesWorn: [daysAgo(1), daysAgo(2), daysAgo(3)]),
            makeWatch(brand: "Two", datesWorn: [daysAgo(1), daysAgo(2)]),
        ]
        let stats = WatchStatistics(watches: watches)
        let ranked = stats.rankedByWear
        #expect(ranked[0].brand == "Three")
        #expect(ranked[1].brand == "Two")
        #expect(ranked[2].brand == "One")
    }

    @Test("rankedByWear returns empty for empty collection")
    func rankedEmpty() {
        let stats = WatchStatistics(watches: [])
        #expect(stats.rankedByWear.isEmpty)
    }

    @Test("rankedByWear includes watches with zero wears at the end")
    func rankedIncludesZeroWears() {
        let watches = [
            makeWatch(brand: "Worn", datesWorn: [daysAgo(1)]),
            makeWatch(brand: "Unworn"),
        ]
        let stats = WatchStatistics(watches: watches)
        let ranked = stats.rankedByWear
        #expect(ranked[0].brand == "Worn")
        #expect(ranked[1].brand == "Unworn")
    }

    // MARK: - wornToday

    @Test("wornToday returns true when today's date is in datesWorn")
    func wornTodayTrue() {
        let watch = makeWatch(datesWorn: [Date()])
        let stats = WatchStatistics(watches: [watch])
        #expect(stats.wornToday(watch) == true)
    }

    @Test("wornToday returns false when only past dates are in datesWorn")
    func wornTodayFalse() {
        let watch = makeWatch(datesWorn: [daysAgo(1)])
        let stats = WatchStatistics(watches: [watch])
        #expect(stats.wornToday(watch) == false)
    }

    @Test("wornToday returns false for empty datesWorn")
    func wornTodayEmpty() {
        let watch = makeWatch(datesWorn: [])
        let stats = WatchStatistics(watches: [watch])
        #expect(stats.wornToday(watch) == false)
    }

    @Test("wornToday returns true when today is mixed with past dates")
    func wornTodayMixed() {
        let watch = makeWatch(datesWorn: [daysAgo(7), daysAgo(1), Date()])
        let stats = WatchStatistics(watches: [watch])
        #expect(stats.wornToday(watch) == true)
    }

    // MARK: - countByBrand

    @Test("countByBrand returns empty for empty collection")
    func countByBrandEmpty() {
        let stats = WatchStatistics(watches: [])
        #expect(stats.countByBrand.isEmpty)
    }

    @Test("countByBrand groups watches by brand with correct counts")
    func countByBrandGroups() {
        let watches = [
            makeWatch(brand: "Rolex"),
            makeWatch(brand: "Rolex"),
            makeWatch(brand: "Omega"),
            makeWatch(brand: "Omega"),
            makeWatch(brand: "Omega"),
            makeWatch(brand: "Seiko"),
        ]
        let stats = WatchStatistics(watches: watches)
        let result = stats.countByBrand
        #expect(result.count == 3)
        #expect(result[0].brand == "Omega")
        #expect(result[0].count == 3)
        #expect(result[1].brand == "Rolex")
        #expect(result[1].count == 2)
        #expect(result[2].brand == "Seiko")
        #expect(result[2].count == 1)
    }

    @Test("countByBrand returns single entry for one brand")
    func countByBrandSingle() {
        let watches = [makeWatch(brand: "Casio"), makeWatch(brand: "Casio")]
        let stats = WatchStatistics(watches: watches)
        #expect(stats.countByBrand.count == 1)
        #expect(stats.countByBrand[0].brand == "Casio")
        #expect(stats.countByBrand[0].count == 2)
    }

    // MARK: - countByStyle

    @Test("countByStyle returns empty for empty collection")
    func countByStyleEmpty() {
        let stats = WatchStatistics(watches: [])
        #expect(stats.countByStyle.isEmpty)
    }

    @Test("countByStyle groups watches by style with correct counts")
    func countByStyleGroups() {
        let watches = [
            Watch(brand: "A", model: "M", style: .diver, movement: .automatic, hasBracelet: false, watchStatus: .available, accuracyMethod: .manual, datesWorn: []),
            Watch(brand: "B", model: "M", style: .diver, movement: .automatic, hasBracelet: false, watchStatus: .available, accuracyMethod: .manual, datesWorn: []),
            Watch(brand: "C", model: "M", style: .dress, movement: .automatic, hasBracelet: false, watchStatus: .available, accuracyMethod: .manual, datesWorn: []),
        ]
        let stats = WatchStatistics(watches: watches)
        let result = stats.countByStyle
        #expect(result.count == 2)
        #expect(result[0].style == .diver)
        #expect(result[0].count == 2)
        #expect(result[1].style == .dress)
        #expect(result[1].count == 1)
    }

    // MARK: - countByMovement

    @Test("countByMovement returns empty for empty collection")
    func countByMovementEmpty() {
        let stats = WatchStatistics(watches: [])
        #expect(stats.countByMovement.isEmpty)
    }

    @Test("countByMovement groups watches by movement with correct counts")
    func countByMovementGroups() {
        let watches = [
            Watch(brand: "A", model: "M", style: .dress, movement: .quartz, hasBracelet: false, watchStatus: .available, accuracyMethod: .manual, datesWorn: []),
            Watch(brand: "B", model: "M", style: .dress, movement: .quartz, hasBracelet: false, watchStatus: .available, accuracyMethod: .manual, datesWorn: []),
            Watch(brand: "C", model: "M", style: .dress, movement: .automatic, hasBracelet: false, watchStatus: .available, accuracyMethod: .manual, datesWorn: []),
        ]
        let stats = WatchStatistics(watches: watches)
        let result = stats.countByMovement
        #expect(result.count == 2)
        #expect(result[0].movement == .automatic)
        #expect(result[0].count == 1)
        #expect(result[1].movement == .quartz)
        #expect(result[1].count == 2)
    }

    // MARK: - todaysWatch

    @Test("todaysWatch returns nil for empty collection")
    func todaysWatchEmpty() {
        let stats = WatchStatistics(watches: [])
        #expect(stats.todaysWatch == nil)
    }

    @Test("todaysWatch returns nil when no watch worn today")
    func todaysWatchNoneWorn() {
        let watches = [
            makeWatch(brand: "A", datesWorn: [daysAgo(1)]),
            makeWatch(brand: "B", datesWorn: []),
        ]
        let stats = WatchStatistics(watches: watches)
        #expect(stats.todaysWatch == nil)
    }

    @Test("todaysWatch returns the watch worn today")
    func todaysWatchFindsToday() {
        let watches = [
            makeWatch(brand: "Yesterday", datesWorn: [daysAgo(1)]),
            makeWatch(brand: "Today", datesWorn: [Date()]),
            makeWatch(brand: "Never"),
        ]
        let stats = WatchStatistics(watches: watches)
        #expect(stats.todaysWatch?.brand == "Today")
    }

    @Test("todaysWatch returns the most recently selected watch when multiple worn today")
    func todaysWatchMostRecent() {
        let earlier = Date().addingTimeInterval(-3600)
        let later = Date()
        let watches = [
            makeWatch(brand: "Earlier", datesWorn: [earlier]),
            makeWatch(brand: "Later", datesWorn: [later]),
        ]
        let stats = WatchStatistics(watches: watches)
        #expect(stats.todaysWatch?.brand == "Later")
    }

    @Test("todaysWatch picks watch with latest timestamp when both worn today")
    func todaysWatchSwitchScenario() {
        // Simulates: select A, then switch to B
        // A was selected first (earlier timestamp), B selected after (later timestamp)
        let firstSelection = Date().addingTimeInterval(-600)
        let secondSelection = Date()
        let watches = [
            makeWatch(brand: "WatchA", datesWorn: [daysAgo(1), daysAgo(2), firstSelection]),
            makeWatch(brand: "WatchB", datesWorn: [secondSelection]),
        ]
        let stats = WatchStatistics(watches: watches)
        #expect(stats.todaysWatch?.brand == "WatchB")
    }

    // MARK: - wearsByDayOfWeek

    @Test("wearsByDayOfWeek always returns exactly 7 entries")
    func wearsByDayOfWeekAlwaysSevenEntries() {
        #expect(WatchStatistics(watches: []).wearsByDayOfWeek.count == 7)
        #expect(WatchStatistics(watches: [makeWatch(datesWorn: [daysAgo(1)])]).wearsByDayOfWeek.count == 7)
    }

    @Test("wearsByDayOfWeek weekday values are always 1 through 7 in order")
    func wearsByDayOfWeekWeekdayValues() {
        let stats = WatchStatistics(watches: [makeWatch(datesWorn: [daysAgo(1)])])
        #expect(stats.wearsByDayOfWeek.map(\.weekday) == Array(1...7))
    }

    @Test("wearsByDayOfWeek counts are zero for empty collection")
    func wearsByDayOfWeekZeroWhenEmpty() {
        let stats = WatchStatistics(watches: [])
        #expect(stats.wearsByDayOfWeek.allSatisfy { $0.count == 0 })
    }

    @Test("wearsByDayOfWeek increments count for the correct weekday")
    func wearsByDayOfWeekCorrectDayCount() {
        let today = Date()
        let weekday = Calendar.current.component(.weekday, from: today)
        let stats = WatchStatistics(watches: [makeWatch(datesWorn: [today])])
        let entry = stats.wearsByDayOfWeek.first { $0.weekday == weekday }
        #expect(entry?.count == 1)
    }

    @Test("wearsByDayOfWeek deduplicates multiple wears on the same day")
    func wearsByDayOfWeekDeduplicatesSameDay() {
        let today = Date()
        let alsoToday = today.addingTimeInterval(3600)
        let weekday = Calendar.current.component(.weekday, from: today)
        let stats = WatchStatistics(watches: [makeWatch(datesWorn: [today, alsoToday])])
        let entry = stats.wearsByDayOfWeek.first { $0.weekday == weekday }
        #expect(entry?.count == 1)
    }

    // MARK: - activeRotationCount

    @Test("activeRotationCount returns 0 for empty collection")
    func activeRotationCountEmpty() {
        #expect(WatchStatistics(watches: []).activeRotationCount == 0)
    }

    @Test("activeRotationCount returns 0 when all wears are older than 30 days")
    func activeRotationCountOldWears() {
        let watch = makeWatch(datesWorn: [daysAgo(31), daysAgo(60)])
        #expect(WatchStatistics(watches: [watch]).activeRotationCount == 0)
    }

    @Test("activeRotationCount counts only watches worn within the last 30 days")
    func activeRotationCountRecentWears() {
        let watches = [
            makeWatch(brand: "Recent1", datesWorn: [daysAgo(1)]),
            makeWatch(brand: "Recent2", datesWorn: [daysAgo(15)]),
            makeWatch(brand: "Old",     datesWorn: [daysAgo(31)]),
        ]
        #expect(WatchStatistics(watches: watches).activeRotationCount == 2)
    }

    @Test("activeRotationCount includes a watch worn 29 days ago")
    func activeRotationCountBoundary() {
        let watch = makeWatch(datesWorn: [daysAgo(29)])
        #expect(WatchStatistics(watches: [watch]).activeRotationCount == 1)
    }

    @Test("activeRotationCount counts each qualifying watch once regardless of wear frequency")
    func activeRotationCountDeduplicatesWatch() {
        let watch = makeWatch(datesWorn: [daysAgo(1), daysAgo(2), daysAgo(3)])
        #expect(WatchStatistics(watches: [watch]).activeRotationCount == 1)
    }

    // MARK: - currentStreak

    @Test("currentStreak returns nil for empty collection")
    func currentStreakEmpty() {
        #expect(WatchStatistics(watches: []).currentStreak == nil)
    }

    @Test("currentStreak returns nil when most recent wear is two or more days ago")
    func currentStreakStaleWear() {
        let watch = makeWatch(datesWorn: [daysAgo(2)])
        #expect(WatchStatistics(watches: [watch]).currentStreak == nil)
    }

    @Test("currentStreak returns 1 when watch was worn only today")
    func currentStreakOneDay() {
        let watch = makeWatch(brand: "Today", datesWorn: [Date()])
        let streak = WatchStatistics(watches: [watch]).currentStreak
        #expect(streak?.days == 1)
        #expect(streak?.watch.brand == "Today")
    }

    @Test("currentStreak counts consecutive days ending today")
    func currentStreakConsecutiveDays() {
        let watch = makeWatch(brand: "Streak", datesWorn: [Date(), daysAgo(1), daysAgo(2), daysAgo(3)])
        let streak = WatchStatistics(watches: [watch]).currentStreak
        #expect(streak?.days == 4)
    }

    @Test("currentStreak stops counting at a gap in consecutive days")
    func currentStreakStopsAtGap() {
        // Worn today, yesterday, but NOT 2 days ago (gap), then 3 days ago
        let watch = makeWatch(datesWorn: [Date(), daysAgo(1), daysAgo(3)])
        #expect(WatchStatistics(watches: [watch]).currentStreak?.days == 2)
    }

    @Test("currentStreak is valid when most recent wear was yesterday")
    func currentStreakYesterday() {
        let watch = makeWatch(datesWorn: [daysAgo(1), daysAgo(2)])
        let streak = WatchStatistics(watches: [watch]).currentStreak
        #expect(streak?.days == 2)
    }

    // MARK: - longestUnworn

    @Test("longestUnworn returns nil for empty collection")
    func longestUnwornEmpty() {
        #expect(WatchStatistics(watches: []).longestUnworn == nil)
    }

    @Test("longestUnworn returns nil when no available watches have ever been worn")
    func longestUnwornNeverWorn() {
        let watch = makeWatch(datesWorn: [])
        #expect(WatchStatistics(watches: [watch]).longestUnworn == nil)
    }

    @Test("longestUnworn returns the available watch with the most days since last wear")
    func longestUnwornFindsMax() {
        let watches = [
            makeWatch(brand: "Recent",  datesWorn: [daysAgo(5)]),
            makeWatch(brand: "LongAgo", datesWorn: [daysAgo(30)]),
            makeWatch(brand: "Medium",  datesWorn: [daysAgo(10)]),
        ]
        let result = WatchStatistics(watches: watches).longestUnworn
        #expect(result?.watch.brand == "LongAgo")
        #expect(result?.days == 30)
    }

    @Test("longestUnworn excludes non-available watches")
    func longestUnwornExcludesUnavailable() {
        let inService = Watch(
            brand: "InService", model: "M",
            style: .dress, movement: .automatic,
            hasBracelet: false, watchStatus: .inService,
            accuracyMethod: .manual, datesWorn: [daysAgo(100)]
        )
        let available = makeWatch(brand: "Available", datesWorn: [daysAgo(10)])
        let result = WatchStatistics(watches: [inService, available]).longestUnworn
        #expect(result?.watch.brand == "Available")
    }

    // MARK: - favoriteWatchByDayOfWeek

    @Test("favoriteWatchByDayOfWeek returns empty when no watches have been worn")
    func favoriteWatchByDayEmpty() {
        let stats = WatchStatistics(watches: [makeWatch()])
        #expect(stats.favoriteWatchByDayOfWeek.isEmpty)
    }

    @Test("favoriteWatchByDayOfWeek returns empty for empty collection")
    func favoriteWatchByDayEmptyCollection() {
        #expect(WatchStatistics(watches: []).favoriteWatchByDayOfWeek.isEmpty)
    }

    @Test("favoriteWatchByDayOfWeek returns an entry for a weekday that has wears")
    func favoriteWatchByDayHasEntry() {
        let today = Date()
        let symbol = Calendar.current.shortWeekdaySymbols[Calendar.current.component(.weekday, from: today) - 1]
        let watch = makeWatch(brand: "GoTo", datesWorn: [today])
        let stats = WatchStatistics(watches: [watch])
        let entry = stats.favoriteWatchByDayOfWeek.first { $0.symbol == symbol }
        #expect(entry?.watch.brand == "GoTo")
    }

    @Test("favoriteWatchByDayOfWeek picks the most-worn watch for a given weekday")
    func favoriteWatchByDayPicksMostWorn() {
        let today = Date()
        let lastWeek    = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: today)!
        let twoWeeksAgo = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: today)!
        let symbol = Calendar.current.shortWeekdaySymbols[Calendar.current.component(.weekday, from: today) - 1]

        let frequent   = makeWatch(brand: "Frequent",   datesWorn: [today, lastWeek, twoWeeksAgo])
        let occasional = makeWatch(brand: "Occasional", datesWorn: [today])
        let stats = WatchStatistics(watches: [frequent, occasional])

        let entry = stats.favoriteWatchByDayOfWeek.first { $0.symbol == symbol }
        #expect(entry?.watch.brand == "Frequent")
    }

    @Test("favoriteWatchByDayOfWeek symbol values match Calendar shortWeekdaySymbols")
    func favoriteWatchByDaySymbolsAreValid() {
        let watch = makeWatch(datesWorn: [Date(), daysAgo(1), daysAgo(2)])
        let stats = WatchStatistics(watches: [watch])
        let validSymbols = Set(Calendar.current.shortWeekdaySymbols)
        for entry in stats.favoriteWatchByDayOfWeek {
            #expect(validSymbols.contains(entry.symbol), "'\(entry.symbol)' is not a valid short weekday symbol")
        }
    }
}
