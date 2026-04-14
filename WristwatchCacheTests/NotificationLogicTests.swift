//
//  NotificationLogicTests.swift
//  WristwatchCacheTests
//
//  Created by Thomas Cowern on 4/14/26.
//

import Testing
import Foundation
@testable import WristwatchCache

@MainActor
@Suite("Unworn 90 Days Logic Tests")
struct NotificationLogicTests {

    private func makeWatch(
        brand: String = "Test",
        model: String = "Watch",
        watchStatus: WatchStatus = .available,
        datesWorn: [Date] = []
    ) -> Watch {
        Watch(
            brand: brand, model: model,
            style: .dress, movement: .automatic,
            hasBracelet: false, watchStatus: watchStatus,
            accuracyMethod: .manual, datesWorn: datesWorn
        )
    }

    private func daysAgo(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -n, to: Date())!
    }

    // MARK: - notWornIn90Days

    @Test("notWornIn90Days returns empty for empty collection")
    func emptyCollection() {
        let stats = WatchStatistics(watches: [])
        #expect(stats.notWornIn90Days.isEmpty)
    }

    @Test("notWornIn90Days includes available watch with empty datesWorn")
    func neverWornAvailable() {
        let watch = makeWatch(brand: "Neglected")
        let stats = WatchStatistics(watches: [watch])
        #expect(stats.notWornIn90Days.count == 1)
        #expect(stats.notWornIn90Days.first?.brand == "Neglected")
    }

    @Test("notWornIn90Days includes available watch last worn 91 days ago")
    func worn91DaysAgo() {
        let watch = makeWatch(brand: "Old", datesWorn: [daysAgo(91)])
        let stats = WatchStatistics(watches: [watch])
        #expect(stats.notWornIn90Days.count == 1)
    }

    @Test("notWornIn90Days excludes available watch last worn 89 days ago")
    func worn89DaysAgo() {
        let watch = makeWatch(brand: "Recent", datesWorn: [daysAgo(89)])
        let stats = WatchStatistics(watches: [watch])
        #expect(stats.notWornIn90Days.isEmpty)
    }

    @Test("notWornIn90Days excludes available watch worn today")
    func wornToday() {
        let watch = makeWatch(brand: "Active", datesWorn: [Date()])
        let stats = WatchStatistics(watches: [watch])
        #expect(stats.notWornIn90Days.isEmpty)
    }

    @Test("notWornIn90Days excludes non-available watches even if unworn")
    func excludesNonAvailable() {
        let watches = [
            makeWatch(brand: "InService", watchStatus: .inService, datesWorn: []),
            makeWatch(brand: "Selling", watchStatus: .selling, datesWorn: []),
            makeWatch(brand: "InRepair", watchStatus: .inRepair, datesWorn: []),
            makeWatch(brand: "NeedsService", watchStatus: .needsService, datesWorn: []),
            makeWatch(brand: "Damaged", watchStatus: .damaged, datesWorn: []),
        ]
        let stats = WatchStatistics(watches: watches)
        #expect(stats.notWornIn90Days.isEmpty)
    }

    @Test("notWornIn90Days uses most recent date when multiple dates exist")
    func usesMaxDate() {
        let watch = makeWatch(
            brand: "Mixed",
            datesWorn: [daysAgo(200), daysAgo(150), daysAgo(30)]
        )
        let stats = WatchStatistics(watches: [watch])
        #expect(stats.notWornIn90Days.isEmpty)
    }

    @Test("notWornIn90Days returns multiple qualifying watches")
    func multipleQualifying() {
        let watches = [
            makeWatch(brand: "Old1", datesWorn: [daysAgo(100)]),
            makeWatch(brand: "Old2", datesWorn: [daysAgo(120)]),
            makeWatch(brand: "Recent", datesWorn: [daysAgo(10)]),
            makeWatch(brand: "InService", watchStatus: .inService, datesWorn: []),
        ]
        let stats = WatchStatistics(watches: watches)
        #expect(stats.notWornIn90Days.count == 2)
        let brands = stats.notWornIn90Days.map(\.brand)
        #expect(brands.contains("Old1"))
        #expect(brands.contains("Old2"))
    }
}
