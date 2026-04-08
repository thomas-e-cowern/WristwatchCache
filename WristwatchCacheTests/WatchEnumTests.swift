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
        #expect(Style.allCases.count == 20)
    }

    @Test("AccuracyMethod has 3 cases")
    func accuracyMethodCaseCount() {
        #expect(AccuracyMethod.allCases.count == 3)
    }

    // MARK: - WatchStatus Raw Values (all 6)

    @Test("WatchStatus raw values are correct")
    func watchStatusRawValues() {
        #expect(WatchStatus.available.rawValue == "Available")
        #expect(WatchStatus.inService.rawValue == "In for service")
        #expect(WatchStatus.selling.rawValue == "Selling")
        #expect(WatchStatus.inRepair.rawValue == "In for repair")
        #expect(WatchStatus.needsService.rawValue == "Needs service")
        #expect(WatchStatus.damaged.rawValue == "Damaged")
    }

    // MARK: - Movement Raw Values (all 17)

    @Test("Movement raw values are all correct")
    func movementRawValues() {
        #expect(Movement.automatic.rawValue == "Automatic")
        #expect(Movement.handWound.rawValue == "Hand wound")
        #expect(Movement.quartz.rawValue == "Quartz")
        #expect(Movement.solarQuartz.rawValue == "Solar")
        #expect(Movement.kinetic.rawValue == "Kinetic")
        #expect(Movement.springDrive.rawValue == "Spring drive")
        #expect(Movement.tuningFork.rawValue == "Tuning fork")
        #expect(Movement.electroMechanical.rawValue == "Electro-mechanical")
        #expect(Movement.highPrecisionQuartz.rawValue == "High precision quartz")
        #expect(Movement.tempratureCompensatedQuartz.rawValue == "Temperature compensated quartz")
        #expect(Movement.gpsRadioSync.rawValue == "GPS radio sync")
        #expect(Movement.digital.rawValue == "Digital")
        #expect(Movement.tourbillon.rawValue == "Tourbillon")
        #expect(Movement.fuseeChain.rawValue == "Fusee Chain")
        #expect(Movement.remontaire.rawValue == "Remontaire")
        #expect(Movement.microRotor.rawValue == "Micro Rotor")
        #expect(Movement.other.rawValue == "Other")
    }

    // MARK: - Style Raw Values (all 19)

    @Test("Style raw values are all correct")
    func styleRawValues() {
        #expect(Style.diver.rawValue == "Diver")
        #expect(Style.chronograph.rawValue == "Chronograph")
        #expect(Style.dress.rawValue == "Dress")
        #expect(Style.pilot.rawValue == "Pilot")
        #expect(Style.fieldWatch.rawValue == "Field")
        #expect(Style.gmtWatch.rawValue == "GMT")
        #expect(Style.sport.rawValue == "Sport")
        #expect(Style.skeleton.rawValue == "Skeleton")
        #expect(Style.moonPhase.rawValue == "Moon phase")
        #expect(Style.worldTimer.rawValue == "World timer")
        #expect(Style.tonneau.rawValue == "Tonneau")
        #expect(Style.pilotChronograph.rawValue == "Pilot chronograph")
        #expect(Style.racing.rawValue == "Racing")
        #expect(Style.tropical.rawValue == "Tropical")
        #expect(Style.tool.rawValue == "Tool")
        #expect(Style.dressChronograph.rawValue == "Dress chronograph")
        #expect(Style.digital.rawValue == "Digital")
        #expect(Style.military.rawValue == "Military")
        #expect(Style.beater.rawValue == "Beater")
    }

    // MARK: - AccuracyMethod Raw Values (all 3)

    @Test("AccuracyMethod raw values are correct")
    func accuracyMethodRawValues() {
        #expect(AccuracyMethod.manual.rawValue == "Manual")
        #expect(AccuracyMethod.timeGrapher.rawValue == "Time Grapher")
        #expect(AccuracyMethod.other.rawValue == "Other")
    }

    // MARK: - Codable Round-Trip

    @Test("All WatchStatus cases survive JSON encode/decode round-trip")
    func watchStatusCodableRoundTrip() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        for status in WatchStatus.allCases {
            let data = try encoder.encode(status)
            let decoded = try decoder.decode(WatchStatus.self, from: data)
            #expect(decoded == status)
        }
    }

    @Test("All Movement cases survive JSON encode/decode round-trip")
    func movementCodableRoundTrip() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        for movement in Movement.allCases {
            let data = try encoder.encode(movement)
            let decoded = try decoder.decode(Movement.self, from: data)
            #expect(decoded == movement)
        }
    }

    @Test("All Style cases survive JSON encode/decode round-trip")
    func styleCodableRoundTrip() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        for style in Style.allCases {
            let data = try encoder.encode(style)
            let decoded = try decoder.decode(Style.self, from: data)
            #expect(decoded == style)
        }
    }

    @Test("All AccuracyMethod cases survive JSON encode/decode round-trip")
    func accuracyMethodCodableRoundTrip() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        for method in AccuracyMethod.allCases {
            let data = try encoder.encode(method)
            let decoded = try decoder.decode(AccuracyMethod.self, from: data)
            #expect(decoded == method)
        }
    }

    // MARK: - Init from Raw Value

    @Test("WatchStatus can be created from raw value strings")
    func watchStatusFromRawValue() {
        #expect(WatchStatus(rawValue: "Available") == .available)
        #expect(WatchStatus(rawValue: "Damaged") == .damaged)
        #expect(WatchStatus(rawValue: "invalid") == nil)
    }

    @Test("Movement can be created from raw value strings")
    func movementFromRawValue() {
        #expect(Movement(rawValue: "Automatic") == .automatic)
        #expect(Movement(rawValue: "Quartz") == .quartz)
        #expect(Movement(rawValue: "invalid") == nil)
    }

    @Test("Style can be created from raw value strings")
    func styleFromRawValue() {
        #expect(Style(rawValue: "Diver") == .diver)
        #expect(Style(rawValue: "Dress") == .dress)
        #expect(Style(rawValue: "invalid") == nil)
    }
}
