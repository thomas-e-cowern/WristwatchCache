//
//  WatchStatistics.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 4/1/26.
//

import Foundation

struct WatchStatistics {
    let watches: [Watch]

    var totalWears: Int {
        watches.reduce(0) { $0 + $1.datesWorn.count }
    }

    var mostWorn: Watch? {
        watches.max(by: { $0.datesWorn.count < $1.datesWorn.count })
    }

    var neverWorn: [Watch] {
        watches.filter { $0.datesWorn.isEmpty }
    }

    var rankedByWear: [Watch] {
        watches.sorted { $0.datesWorn.count > $1.datesWorn.count }
    }

    func wornToday(_ watch: Watch) -> Bool {
        watch.datesWorn.contains { Calendar.current.isDateInToday($0) }
    }

    var todaysWatch: Watch? {
        watches.first { wornToday($0) }
    }
}
