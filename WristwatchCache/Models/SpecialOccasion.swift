//
//  SpecialOccasion.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 4/20/26.
//

import Foundation
import SwiftData

enum OccasionRecurrence: String, Codable, CaseIterable {
    case none       = "None"
    case weekly     = "Weekly"
    case biweekly   = "Every 2 weeks"
    case monthly    = "Monthly"
    case annually   = "Annually"
}

@Model
class SpecialOccasion {
    var name: String
    var date: Date
    var notes: String
    var recurrence: OccasionRecurrence
    var watch: Watch?

    init(name: String, date: Date, notes: String = "", recurrence: OccasionRecurrence = .none, watch: Watch? = nil) {
        self.name = name
        self.date = date
        self.notes = notes
        self.recurrence = recurrence
        self.watch = watch
    }

    /// The next calendar date this occasion falls on (today counts).
    /// Returns `nil` for non-repeating occasions.
    var nextOccurrence: Date? {
        guard recurrence != .none else { return nil }
        let calendar = Calendar.current
        // Subtract one day so "today" is included in nextDate(after:)
        let beforeToday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: .now))!

        switch recurrence {
        case .none:
            return nil

        case .weekly:
            let weekday = calendar.component(.weekday, from: date)
            return calendar.nextDate(
                after: beforeToday,
                matching: DateComponents(weekday: weekday),
                matchingPolicy: .nextTime
            )

        case .biweekly:
            let startOfToday = calendar.startOfDay(for: .now)
            let startOfOrigin = calendar.startOfDay(for: date)
            let daysSince = calendar.dateComponents([.day], from: startOfOrigin, to: startOfToday).day ?? 0
            guard daysSince >= 0 else { return startOfOrigin }
            let daysIntoCurrentCycle = daysSince % 14
            let daysUntilNext = daysIntoCurrentCycle == 0 ? 0 : 14 - daysIntoCurrentCycle
            return calendar.date(byAdding: .day, value: daysUntilNext, to: startOfToday)

        case .monthly:
            let day = calendar.component(.day, from: date)
            return calendar.nextDate(
                after: beforeToday,
                matching: DateComponents(day: day),
                matchingPolicy: .nextTimePreservingSmallerComponents
            )

        case .annually:
            let month = calendar.component(.month, from: date)
            let day   = calendar.component(.day,   from: date)
            return calendar.nextDate(
                after: beforeToday,
                matching: DateComponents(month: month, day: day),
                matchingPolicy: .nextTimePreservingSmallerComponents
            )
        }
    }

    /// The date used for sorting and display: next occurrence for repeating, stored date otherwise.
    var effectiveDate: Date {
        nextOccurrence ?? date
    }
}
