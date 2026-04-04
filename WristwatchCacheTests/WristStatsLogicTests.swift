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

    // MARK: - totalWears

    @Test("totalWears returns 0 for empty collection")
    func totalWearsEmpty() {
        let stats = WatchStatistics(watches: [])
        #expect(stats.totalWears == 0)
    }

    @Test("totalWears sums all datesWorn counts")
    func totalWearsSum() {
        let past = Date(timeIntervalSince1970: 1000000)
        let watches = [
            makeWatch(datesWorn: [past, past]),
            makeWatch(datesWorn: [past]),
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

    @Test("totalWears works with single watch")
    func totalWearsSingle() {
        let past = Date(timeIntervalSince1970: 1000000)
        let watches = [makeWatch(datesWorn: [past, past, past])]
        let stats = WatchStatistics(watches: watches)
        #expect(stats.totalWears == 3)
    }

    // MARK: - mostWorn

    @Test("mostWorn returns nil for empty collection")
    func mostWornEmpty() {
        let stats = WatchStatistics(watches: [])
        #expect(stats.mostWorn == nil)
    }

    @Test("mostWorn returns watch with most dates worn")
    func mostWornFindsMax() {
        let past = Date(timeIntervalSince1970: 1000000)
        let watches = [
            makeWatch(brand: "One", datesWorn: [past]),
            makeWatch(brand: "Winner", datesWorn: [past, past, past]),
            makeWatch(brand: "Two", datesWorn: [past, past]),
        ]
        let stats = WatchStatistics(watches: watches)
        #expect(stats.mostWorn?.brand == "Winner")
    }

    @Test("mostWorn returns a watch when all have zero wears")
    func mostWornAllZero() {
        let watches = [makeWatch(brand: "A"), makeWatch(brand: "B")]
        let stats = WatchStatistics(watches: watches)
        // max(by:) returns last element when all are equal, but we just check it's non-nil
        #expect(stats.mostWorn != nil)
    }

    @Test("mostWorn works with single watch")
    func mostWornSingle() {
        let past = Date(timeIntervalSince1970: 1000000)
        let watch = makeWatch(brand: "Only", datesWorn: [past])
        let stats = WatchStatistics(watches: [watch])
        #expect(stats.mostWorn?.brand == "Only")
    }

    // MARK: - neverWorn

    @Test("neverWorn returns empty when all watches have been worn")
    func neverWornAllWorn() {
        let past = Date(timeIntervalSince1970: 1000000)
        let watches = [
            makeWatch(datesWorn: [past]),
            makeWatch(datesWorn: [past]),
        ]
        let stats = WatchStatistics(watches: watches)
        #expect(stats.neverWorn.isEmpty)
    }

    @Test("neverWorn filters watches with empty datesWorn")
    func neverWornFilters() {
        let past = Date(timeIntervalSince1970: 1000000)
        let watches = [
            makeWatch(brand: "Worn", datesWorn: [past]),
            makeWatch(brand: "Unworn"),
            makeWatch(brand: "AlsoWorn", datesWorn: [past]),
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

    @Test("rankedByWear sorts descending by wear count")
    func rankedDescending() {
        let past = Date(timeIntervalSince1970: 1000000)
        let watches = [
            makeWatch(brand: "One", datesWorn: [past]),
            makeWatch(brand: "Three", datesWorn: [past, past, past]),
            makeWatch(brand: "Two", datesWorn: [past, past]),
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
        let past = Date(timeIntervalSince1970: 1000000)
        let watches = [
            makeWatch(brand: "Worn", datesWorn: [past]),
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
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let watch = makeWatch(datesWorn: [yesterday])
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
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let watch = makeWatch(datesWorn: [lastWeek, yesterday, Date()])
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
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let watches = [
            makeWatch(brand: "A", datesWorn: [yesterday]),
            makeWatch(brand: "B", datesWorn: []),
        ]
        let stats = WatchStatistics(watches: watches)
        #expect(stats.todaysWatch == nil)
    }

    @Test("todaysWatch returns the watch worn today")
    func todaysWatchFindsToday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let watches = [
            makeWatch(brand: "Yesterday", datesWorn: [yesterday]),
            makeWatch(brand: "Today", datesWorn: [Date()]),
            makeWatch(brand: "Never"),
        ]
        let stats = WatchStatistics(watches: watches)
        #expect(stats.todaysWatch?.brand == "Today")
    }

    @Test("todaysWatch returns first watch when multiple worn today")
    func todaysWatchMultiple() {
        let watches = [
            makeWatch(brand: "First", datesWorn: [Date()]),
            makeWatch(brand: "Second", datesWorn: [Date()]),
        ]
        let stats = WatchStatistics(watches: watches)
        #expect(stats.todaysWatch?.brand == "First")
    }
}
