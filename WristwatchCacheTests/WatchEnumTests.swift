//
//  WatchEnumTests.swift
//  WristwatchCacheTests
//
//  Created by Thomas Cowern on 4/1/26.
//

import Testing
import Foundation
@testable import WristwatchCache

@Suite("Watch Enum Tests")
struct WatchEnumTests {

    // MARK: - Case Counts

    @Test("WatchStatus has 6 cases")
    func watchStatusCaseCount() {
        #expect(WatchStatus.allCases.count == 6)
    }

    @Test("Movement has 17 cases")
    func movementCaseCount() {
        #expect(Movement.allCases.count == 17)
    }

    @Test("Style has 19 cases")
    func styleCaseCount() {
        #expect(Style.allCases.count == 19)
    }

    @Test("AccuracyMethod has 3 cases")
    func accuracyMethodCaseCount() {
        #expect(AccuracyMethod.allCases.count == 3)
    }

    // MARK: - Raw Values

    @Test("WatchStatus raw values are correct")
    func watchStatusRawValues() {
        #expect(WatchStatus.available.rawValue == "Available")
        #expect(WatchStatus.inService.rawValue == "In for service")
        #expect(WatchStatus.selling.rawValue == "Selling")
        #expect(WatchStatus.inRepair.rawValue == "In for repair")
        #expect(WatchStatus.needsService.rawValue == "Needs service")
        #expect(WatchStatus.damaged.rawValue == "Damaged")
    }

    @Test("Movement selected raw values are correct")
    func movementRawValues() {
        #expect(Movement.automatic.rawValue == "Automatic")
        #expect(Movement.quartz.rawValue == "Quartz")
        #expect(Movement.springDrive.rawValue == "Spring drive")
        #expect(Movement.digital.rawValue == "Digital")
        #expect(Movement.tourbillon.rawValue == "Tourbillon")
    }

    @Test("Style selected raw values are correct")
    func styleRawValues() {
        #expect(Style.diver.rawValue == "Diver")
        #expect(Style.chronograph.rawValue == "Chronograph")
        #expect(Style.dress.rawValue == "Dress")
        #expect(Style.pilot.rawValue == "Pilot")
        #expect(Style.beater.rawValue == "Beater")
    }

    @Test("AccuracyMethod raw values are correct")
    func accuracyMethodRawValues() {
        #expect(AccuracyMethod.manual.rawValue == "Manual")
        #expect(AccuracyMethod.timeGrapher.rawValue == "Time Grapher")
        #expect(AccuracyMethod.other.rawValue == "Other")
    }

    // MARK: - Codable Round-Trip

    @Test("All enums survive JSON encode/decode round-trip")
    func codableRoundTrip() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for status in WatchStatus.allCases {
            let data = try encoder.encode(status)
            let decoded = try decoder.decode(WatchStatus.self, from: data)
            #expect(decoded == status)
        }

        for movement in Movement.allCases {
            let data = try encoder.encode(movement)
            let decoded = try decoder.decode(Movement.self, from: data)
            #expect(decoded == movement)
        }

        for style in Style.allCases {
            let data = try encoder.encode(style)
            let decoded = try decoder.decode(Style.self, from: data)
            #expect(decoded == style)
        }

        for method in AccuracyMethod.allCases {
            let data = try encoder.encode(method)
            let decoded = try decoder.decode(AccuracyMethod.self, from: data)
            #expect(decoded == method)
        }
    }
}
