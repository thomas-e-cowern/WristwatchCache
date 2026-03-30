//
//  Watch.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 3/30/26.
//

import Foundation
import SwiftData

@Model
class Watch {
    
    // Basic info
    var brand: String
    var model: String
    var style: String
    var movement: String
    
    // Basic size info
    var caseDiameter: Double?
    var lugWidth: Double?
    
    // Do you have a bracelet?
    var hasBracelet: Bool = false
    
    // Service info
    var lastBatteryChange: Date?
    var lastServiced: Date?
    
    // Watch status
    var watchStatus: WatchStatus = WatchStatus.available
    
    // Accuracy info
    var accuracy: Double?
    var accuracyMethod: AccuracyMethod = AccuracyMethod.manual
    
    var dateHacked: Date?
    
    // Frequency of wear
    var datesWorn: [Date] = []
    
    init(brand: String, model: String, style: String, movement: String, caseDiameter: Double? = nil, lugWidth: Double? = nil, hasBracelet: Bool, lastBatteryChange: Date? = nil, lastServiced: Date? = nil, watchStatus: WatchStatus, accuracy: Double? = nil, accuracyMethod: AccuracyMethod, dateHacked: Date? = nil, datesWorn: [Date]) {
        self.brand = brand
        self.model = model
        self.style = style
        self.movement = movement
        self.caseDiameter = caseDiameter
        self.lugWidth = lugWidth
        self.hasBracelet = hasBracelet
        self.lastBatteryChange = lastBatteryChange
        self.lastServiced = lastServiced
        self.watchStatus = watchStatus
        self.accuracy = accuracy
        self.accuracyMethod = accuracyMethod
        self.dateHacked = dateHacked
        self.datesWorn = datesWorn
    }
    
}

enum WatchStatus: String, Codable {
    case available, inService, selling, inRepair, needsService, damaged
}

enum AccuracyMethod: String, Codable {
    case manual, timeGrapher, other
}

extension Watch {
    static var sampleData: [Watch] {
        return [
            Watch(brand: "Seiko", model: "SKX007", style: "Diver", movement: "Automatic", caseDiameter: 42.0, lugWidth: 22.0, hasBracelet: true, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1561939200), watchStatus: .available, accuracy: -4.0, accuracyMethod: .timeGrapher, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1711920000), Date(timeIntervalSince1970: 1712006400)]),
            Watch(brand: "Seiko", model: "Alpinist SARB017", style: "Field", movement: "Automatic", caseDiameter: 38.0, lugWidth: 20.0, hasBracelet: false, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1501545600), watchStatus: .available, accuracy: +6.0, accuracyMethod: .manual, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1709001600)]),
            Watch(brand: "Citizen", model: "Presage Cocktail SRPB41", style: "Dress", movement: "Automatic", caseDiameter: 40.5, lugWidth: 20.0, hasBracelet: false, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1601510400), watchStatus: .available, accuracy: +3.0, accuracyMethod: .timeGrapher, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1698796800), Date(timeIntervalSince1970: 1701388800)]),
            Watch(brand: "Timex", model: "Presage SARX055", style: "Dress", movement: "Automatic", caseDiameter: 41.0, lugWidth: 21.0, hasBracelet: true, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1483228800), watchStatus: .needsService, accuracy: nil, accuracyMethod: .other, dateHacked: nil, datesWorn: []),
            Watch(brand: "Swatch", model: "5 SNK809", style: "Casual", movement: "Automatic", caseDiameter: 37.0, lugWidth: 18.0, hasBracelet: false, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1625097600), watchStatus: .available, accuracy: +12.0, accuracyMethod: .manual, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1710288000)]),
            Watch(brand: "Seiko", model: "SLA017 MarineMaster", style: "Diver", movement: "Automatic (Hi-Beat)", caseDiameter: 44.0, lugWidth: 22.0, hasBracelet: true, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1580515200), watchStatus: .available, accuracy: -2.0, accuracyMethod: .timeGrapher, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1704067200), Date(timeIntervalSince1970: 1706659200)]),
            Watch(brand: "Seiko", model: "Astron GPS SSE041", style: "Sport", movement: "Quartz GPS", caseDiameter: 44.6, lugWidth: 22.0, hasBracelet: true, lastBatteryChange: Date(timeIntervalSince1970: 1688169600), lastServiced: nil, watchStatus: .available, accuracy: 0.0, accuracyMethod: .other, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1711776000)]),
            Watch(brand: "Seiko", model: "Prospex Turtle SRP777", style: "Diver", movement: "Automatic", caseDiameter: 45.0, lugWidth: 22.0, hasBracelet: true, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1614556800), watchStatus: .inService, accuracy: +5.0, accuracyMethod: .manual, dateHacked: nil, datesWorn: []),
            Watch(brand: "Seiko", model: "SNZH55", style: "Diver-style", movement: "Automatic", caseDiameter: 41.0, lugWidth: 22.0, hasBracelet: false, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1575158400), watchStatus: .selling, accuracy: +9.0, accuracyMethod: .manual, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1696118400)]),
            Watch(brand: "Seiko", model: "Brightz SAGA001", style: "Dress", movement: "Solar Chronograph", caseDiameter: 43.0, lugWidth: 21.0, hasBracelet: true, lastBatteryChange: Date(timeIntervalSince1970: 1698777600), lastServiced: nil, watchStatus: .available, accuracy: 0.0, accuracyMethod: .other, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1704043200)]),
            Watch(brand: "Seiko", model: "King Seiko SJE087", style: "Dress", movement: "Automatic (Hi-Beat)", caseDiameter: 38.5, lugWidth: 19.0, hasBracelet: false, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1409673600), watchStatus: .available, accuracy: +1.0, accuracyMethod: .timeGrapher, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1708684800)]),
            Watch(brand: "Seiko", model: "Monaco-inspired Reissue", style: "Chronograph", movement: "Automatic Chronograph", caseDiameter: 39.5, lugWidth: 20.0, hasBracelet: false, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1493596800), watchStatus: .inRepair, accuracy: nil, accuracyMethod: .other, dateHacked: nil, datesWorn: []),
            Watch(brand: "Seiko", model: "SNKP27", style: "Dress", movement: "Automatic", caseDiameter: 36.0, lugWidth: 18.0, hasBracelet: false, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1514764800), watchStatus: .available, accuracy: +7.0, accuracyMethod: .manual, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1693526400), Date(timeIntervalSince1970: 1696118400)]),
            Watch(brand: "Seiko", model: "Prospex Sumo SBDC031", style: "Diver", movement: "Automatic", caseDiameter: 44.0, lugWidth: 20.0, hasBracelet: true, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1551398400), watchStatus: .available, accuracy: -1.0, accuracyMethod: .timeGrapher, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1701417600)]),
            Watch(brand: "Seiko", model: "Diver SKX013", style: "Diver (small)", movement: "Automatic", caseDiameter: 38.0, lugWidth: 20.0, hasBracelet: false, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1530403200), watchStatus: .damaged, accuracy: nil, accuracyMethod: .other, dateHacked: nil, datesWorn: []),
            Watch(brand: "Seiko", model: "Velatura Kinetic SRH017", style: "Sport", movement: "Kinetic", caseDiameter: 44.0, lugWidth: 22.0, hasBracelet: true, lastBatteryChange: Date(timeIntervalSince1970: 1672444800), lastServiced: nil, watchStatus: .available, accuracy: +0.5, accuracyMethod: .other, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1711363200)]),
            Watch(brand: "Seiko", model: "Chariot 7019-8110 Reissue", style: "Vintage", movement: "Automatic", caseDiameter: 36.0, lugWidth: 18.0, hasBracelet: false, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1451606400), watchStatus: .selling, accuracy: +10.0, accuracyMethod: .manual, dateHacked: nil, datesWorn: []),
            Watch(brand: "Seiko", model: "SSA413 Presage", style: "Dress", movement: "Automatic (Power Reserve)", caseDiameter: 40.5, lugWidth: 20.0, hasBracelet: false, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1593561600), watchStatus: .available, accuracy: +4.0, accuracyMethod: .timeGrapher, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1709475200)]),
            Watch(brand: "Seiko", model: "Recraft SNKM97", style: "Retro", movement: "Automatic", caseDiameter: 43.0, lugWidth: 22.0, hasBracelet: false, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1546300800), watchStatus: .available, accuracy: +8.0, accuracyMethod: .manual, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1699852800)]),
            Watch(brand: "Seiko", model: "SNJ025 (H558 reissue)", style: "Diver", movement: "Hybrid (Quartz + Digital)", caseDiameter: 47.0, lugWidth: 24.0, hasBracelet: true, lastBatteryChange: Date(timeIntervalSince1970: 1704067200), lastServiced: nil, watchStatus: .inService, accuracy: 0.0, accuracyMethod: .other, dateHacked: nil, datesWorn: [])
        ]
    }
}
