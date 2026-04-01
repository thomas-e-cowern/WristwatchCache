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
}
