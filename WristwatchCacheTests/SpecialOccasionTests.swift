//
//  SpecialOccasionTests.swift
//  WristwatchCacheTests
//
//  Created by Thomas Cowern on 4/20/26.
//

import Testing
import Foundation
import SwiftData
@testable import WristwatchCache

@MainActor
@Suite("Special Occasion Tests")
struct SpecialOccasionTests {

    private let calendar = Calendar.current
    private var today: Date { calendar.startOfDay(for: .now) }

    private func daysAgo(_ n: Int) -> Date {
        calendar.date(byAdding: .day, value: -n, to: today)!
    }

    private func daysFromNow(_ n: Int) -> Date {
        calendar.date(byAdding: .day, value: n, to: today)!
    }

    private func makeWatch() -> Watch {
        Watch(
            brand: "Rolex", model: "Submariner",
            style: .diver, movement: .automatic,
            hasBracelet: true, watchStatus: .available,
            accuracyMethod: .manual, datesWorn: []
        )
    }

    // MARK: - Initialization

    @Test("SpecialOccasion initializes with correct defaults")
    func initDefaults() {
        let date = Date()
        let occasion = SpecialOccasion(name: "Blue Watch Monday", date: date)
        #expect(occasion.name == "Blue Watch Monday")
        #expect(occasion.date == date)
        #expect(occasion.notes == "")
        #expect(occasion.recurrence == .none)
        #expect(occasion.watch == nil)
    }

    @Test("SpecialOccasion initializes with all properties")
    func initAllProperties() {
        let date = Date()
        let watch = makeWatch()
        let occasion = SpecialOccasion(name: "Graduation", date: date, notes: "First grown-up watch", recurrence: .annually, watch: watch)
        #expect(occasion.name == "Graduation")
        #expect(occasion.notes == "First grown-up watch")
        #expect(occasion.recurrence == .annually)
        #expect(occasion.watch === watch)
    }

    // MARK: - nextOccurrence: none

    @Test("nextOccurrence returns nil for non-repeating occasion")
    func nextOccurrenceNone() {
        let occasion = SpecialOccasion(name: "Graduation", date: daysAgo(365), recurrence: .none)
        #expect(occasion.nextOccurrence == nil)
    }

    // MARK: - nextOccurrence: weekly

    @Test("nextOccurrence returns today for weekly occasion whose weekday matches today")
    func nextOccurrenceWeeklyMatchesToday() {
        let occasion = SpecialOccasion(name: "Blue Watch Monday", date: today, recurrence: .weekly)
        let next = occasion.nextOccurrence
        #expect(next != nil)
        #expect(calendar.isDate(next!, inSameDayAs: today))
    }

    @Test("nextOccurrence returns correct future weekday for weekly occasion")
    func nextOccurrenceWeeklyFuture() {
        let yesterday = daysAgo(1)
        let occasion = SpecialOccasion(name: "Test", date: yesterday, recurrence: .weekly)
        let next = occasion.nextOccurrence
        #expect(next != nil)
        // Next occurrence must be on the same weekday as the origin date
        let nextWeekday   = calendar.component(.weekday, from: next!)
        let originWeekday = calendar.component(.weekday, from: yesterday)
        #expect(nextWeekday == originWeekday)
        // And must be strictly after today since yesterday's weekday has passed
        #expect(next! > today)
    }

    // MARK: - nextOccurrence: biweekly

    @Test("nextOccurrence returns today for biweekly occasion with origin == today")
    func nextOccurrenceBiweeklyOriginToday() {
        let occasion = SpecialOccasion(name: "Test", date: today, recurrence: .biweekly)
        let next = occasion.nextOccurrence
        #expect(next != nil)
        #expect(calendar.isDate(next!, inSameDayAs: today))
    }

    @Test("nextOccurrence returns today for biweekly occasion exactly 14 days after origin")
    func nextOccurrenceBiweeklyOnCycle() {
        let occasion = SpecialOccasion(name: "Test", date: daysAgo(14), recurrence: .biweekly)
        let next = occasion.nextOccurrence
        #expect(next != nil)
        #expect(calendar.isDate(next!, inSameDayAs: today))
    }

    @Test("nextOccurrence returns today for biweekly occasion exactly 28 days after origin")
    func nextOccurrenceBiweeklyMultipleCycles() {
        let occasion = SpecialOccasion(name: "Test", date: daysAgo(28), recurrence: .biweekly)
        let next = occasion.nextOccurrence
        #expect(next != nil)
        #expect(calendar.isDate(next!, inSameDayAs: today))
    }

    @Test("nextOccurrence returns correct mid-cycle future date for biweekly occasion")
    func nextOccurrenceBiweeklyMidCycle() {
        // 7 days into the 14-day cycle → 7 days remain
        let occasion = SpecialOccasion(name: "Test", date: daysAgo(7), recurrence: .biweekly)
        let next = occasion.nextOccurrence
        #expect(next != nil)
        #expect(calendar.isDate(next!, inSameDayAs: daysFromNow(7)))
    }

    @Test("nextOccurrence returns origin date for biweekly occasion with future origin")
    func nextOccurrenceBiweeklyFutureOrigin() {
        let futureDate = daysFromNow(5)
        let occasion = SpecialOccasion(name: "Test", date: futureDate, recurrence: .biweekly)
        let next = occasion.nextOccurrence
        #expect(next != nil)
        #expect(calendar.isDate(next!, inSameDayAs: futureDate))
    }

    // MARK: - nextOccurrence: monthly

    @Test("nextOccurrence returns today for monthly occasion whose day-of-month matches today")
    func nextOccurrenceMonthlyMatchesToday() {
        let occasion = SpecialOccasion(name: "Test", date: today, recurrence: .monthly)
        let next = occasion.nextOccurrence
        #expect(next != nil)
        #expect(calendar.isDate(next!, inSameDayAs: today))
    }

    @Test("nextOccurrence returns correct future day-of-month for monthly occasion")
    func nextOccurrenceMonthlyFuture() {
        let yesterday = daysAgo(1)
        let occasion = SpecialOccasion(name: "Test", date: yesterday, recurrence: .monthly)
        let next = occasion.nextOccurrence
        #expect(next != nil)
        // Same day-of-month as origin
        let nextDay   = calendar.component(.day, from: next!)
        let originDay = calendar.component(.day, from: yesterday)
        #expect(nextDay == originDay)
        // Must be in the future
        #expect(next! > today)
    }

    // MARK: - nextOccurrence: annually

    @Test("nextOccurrence returns today for annually occasion whose month and day match today")
    func nextOccurrenceAnnuallyMatchesToday() {
        let occasion = SpecialOccasion(name: "Test", date: today, recurrence: .annually)
        let next = occasion.nextOccurrence
        #expect(next != nil)
        #expect(calendar.isDate(next!, inSameDayAs: today))
    }

    @Test("nextOccurrence returns correct future month and day for annually occasion")
    func nextOccurrenceAnnuallyFuture() {
        let yesterday = daysAgo(1)
        let occasion = SpecialOccasion(name: "St. Patrick's Day", date: yesterday, recurrence: .annually)
        let next = occasion.nextOccurrence
        #expect(next != nil)
        // Same month and day as origin
        let nextMonth   = calendar.component(.month, from: next!)
        let nextDay     = calendar.component(.day,   from: next!)
        let originMonth = calendar.component(.month, from: yesterday)
        let originDay   = calendar.component(.day,   from: yesterday)
        #expect(nextMonth == originMonth)
        #expect(nextDay == originDay)
        // Must be in the future (next year)
        #expect(next! > today)
    }

    // MARK: - effectiveDate

    @Test("effectiveDate returns stored date for non-repeating occasion")
    func effectiveDateNone() {
        let date = daysAgo(30)
        let occasion = SpecialOccasion(name: "Graduation", date: date, recurrence: .none)
        #expect(occasion.effectiveDate == date)
    }

    @Test("effectiveDate equals nextOccurrence for weekly occasion")
    func effectiveDateWeekly() {
        let occasion = SpecialOccasion(name: "Blue Watch Monday", date: today, recurrence: .weekly)
        #expect(occasion.effectiveDate == occasion.nextOccurrence)
    }

    @Test("effectiveDate equals nextOccurrence for biweekly occasion")
    func effectiveDateBiweekly() {
        let occasion = SpecialOccasion(name: "Test", date: daysAgo(14), recurrence: .biweekly)
        #expect(occasion.effectiveDate == occasion.nextOccurrence)
    }

    @Test("effectiveDate equals nextOccurrence for monthly occasion")
    func effectiveDateMonthly() {
        let occasion = SpecialOccasion(name: "Test", date: today, recurrence: .monthly)
        #expect(occasion.effectiveDate == occasion.nextOccurrence)
    }

    @Test("effectiveDate equals nextOccurrence for annually occasion")
    func effectiveDateAnnually() {
        let occasion = SpecialOccasion(name: "Test", date: today, recurrence: .annually)
        #expect(occasion.effectiveDate == occasion.nextOccurrence)
    }

    // MARK: - SwiftData Persistence

    @Test("SpecialOccasion persists and can be fetched")
    func persistAndFetch() throws {
        let container = try TestModelContainer.make()
        let context = container.mainContext

        let occasion = SpecialOccasion(name: "St. Patrick's Day", date: Date(), notes: "Wear green", recurrence: .annually)
        context.insert(occasion)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<SpecialOccasion>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "St. Patrick's Day")
        #expect(fetched.first?.notes == "Wear green")
        #expect(fetched.first?.recurrence == .annually)
    }

    @Test("All OccasionRecurrence values persist through SwiftData")
    func allRecurrenceValuesPersist() throws {
        let container = try TestModelContainer.make()
        let context = container.mainContext

        for rule in OccasionRecurrence.allCases {
            context.insert(SpecialOccasion(name: rule.rawValue, date: Date(), recurrence: rule))
        }
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<SpecialOccasion>())
        let fetchedRules = Set(fetched.map(\.recurrence))
        #expect(fetchedRules == Set(OccasionRecurrence.allCases))
    }

    @Test("SpecialOccasion without a Watch persists with nil watch")
    func standaloneOccasionPersists() throws {
        let container = try TestModelContainer.make()
        let context = container.mainContext

        context.insert(SpecialOccasion(name: "Graduation", date: Date()))
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<SpecialOccasion>())
        #expect(fetched.first?.watch == nil)
    }

    // MARK: - Watch Relationship

    @Test("SpecialOccasion linked to Watch persists the relationship both ways")
    func watchRelationshipPersists() throws {
        let container = try TestModelContainer.make()
        let context = container.mainContext

        let watch = makeWatch()
        context.insert(watch)

        let occasion = SpecialOccasion(name: "Blue Watch Monday", date: Date(), recurrence: .weekly, watch: watch)
        context.insert(occasion)
        try context.save()

        let fetchedOccasions = try context.fetch(FetchDescriptor<SpecialOccasion>())
        #expect(fetchedOccasions.first?.watch?.brand == "Rolex")

        let fetchedWatches = try context.fetch(FetchDescriptor<Watch>())
        #expect(fetchedWatches.first?.specialOccasions.count == 1)
        #expect(fetchedWatches.first?.specialOccasions.first?.name == "Blue Watch Monday")
    }

    @Test("Watch can have multiple SpecialOccasions")
    func watchMultipleOccasions() throws {
        let container = try TestModelContainer.make()
        let context = container.mainContext

        let watch = makeWatch()
        context.insert(watch)

        context.insert(SpecialOccasion(name: "Blue Watch Monday", date: Date(), recurrence: .weekly, watch: watch))
        context.insert(SpecialOccasion(name: "Graduation",        date: Date(), recurrence: .none,   watch: watch))
        context.insert(SpecialOccasion(name: "St. Patrick's Day", date: Date(), recurrence: .annually, watch: watch))
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Watch>())
        #expect(fetched.first?.specialOccasions.count == 3)
    }

    @Test("Deleting a Watch cascades to delete its SpecialOccasions")
    func cascadeDeleteOccasionsOnWatchDelete() throws {
        let container = try TestModelContainer.make()
        let context = container.mainContext

        let watch = makeWatch()
        context.insert(watch)
        context.insert(SpecialOccasion(name: "Test", date: Date(), watch: watch))
        context.insert(SpecialOccasion(name: "Test 2", date: Date(), watch: watch))
        try context.save()

        context.delete(watch)
        try context.save()

        #expect(try context.fetch(FetchDescriptor<Watch>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<SpecialOccasion>()).isEmpty)
    }

    @Test("Deleting a standalone SpecialOccasion does not affect the Watch")
    func deletingOccasionLeavesWatchIntact() throws {
        let container = try TestModelContainer.make()
        let context = container.mainContext

        let watch = makeWatch()
        context.insert(watch)

        let occasion = SpecialOccasion(name: "Test", date: Date(), watch: watch)
        context.insert(occasion)
        try context.save()

        context.delete(occasion)
        try context.save()

        let fetchedWatches = try context.fetch(FetchDescriptor<Watch>())
        #expect(fetchedWatches.count == 1)
        #expect(fetchedWatches.first?.specialOccasions.isEmpty == true)

        let fetchedOccasions = try context.fetch(FetchDescriptor<SpecialOccasion>())
        #expect(fetchedOccasions.isEmpty)
    }
}
