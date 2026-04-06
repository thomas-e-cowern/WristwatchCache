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
}
