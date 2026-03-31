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
    
    // Photo
    @Attribute(.externalStorage) var photo: Data?
    
    // Favorite
    var favorite: Bool = false
    
    init(brand: String, model: String, style: String, movement: String, caseDiameter: Double? = nil, lugWidth: Double? = nil, hasBracelet: Bool, lastBatteryChange: Date? = nil, lastServiced: Date? = nil, watchStatus: WatchStatus, accuracy: Double? = nil, accuracyMethod: AccuracyMethod, dateHacked: Date? = nil, datesWorn: [Date], photo: Data? = nil, favorite: Bool = false) {
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
        self.photo = photo
        self.favorite = favorite
    }
    
}

enum WatchStatus: String, Codable, CaseIterable {
    case available, inService, selling, inRepair, needsService, damaged
}

enum AccuracyMethod: String, Codable, CaseIterable {
    case manual, timeGrapher, other
}

extension Watch {
    static var sampleData: [Watch] {
        return [
            Watch(brand: "Rolex", model: "Submariner Date 126610LN", style: "Diver", movement: "Automatic", caseDiameter: 41.0, lugWidth: 20.0, hasBracelet: true, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1680307200), watchStatus: .available, accuracy: -1.0, accuracyMethod: .timeGrapher, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1711776000), Date(timeIntervalSince1970: 1711862400)], favorite: false),
            Watch(brand: "Omega", model: "Speedmaster Professional", style: "Chronograph", movement: "Manual", caseDiameter: 42.0, lugWidth: 20.0, hasBracelet: true, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1627776000), watchStatus: .available, accuracy: +2.0, accuracyMethod: .timeGrapher, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1710288000)], favorite: true),
            Watch(brand: "Grand Seiko", model: "SBGA211 Snowflake", style: "Dress", movement: "Spring Drive", caseDiameter: 41.0, lugWidth: 20.0, hasBracelet: true, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1609459200), watchStatus: .available, accuracy: 0.0, accuracyMethod: .timeGrapher, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1708992000)], favorite: false),
            Watch(brand: "TAG Heuer", model: "Carrera Calibre 16", style: "Chronograph", movement: "Automatic Chronograph", caseDiameter: 41.0, lugWidth: 21.0, hasBracelet: true, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1598918400), watchStatus: .inService, accuracy: +4.0, accuracyMethod: .manual, dateHacked: nil, datesWorn: [], favorite: false),
            Watch(brand: "Patek Philippe", model: "Nautilus 5711/1A", style: "Sport/Luxury", movement: "Automatic", caseDiameter: 40.0, lugWidth: 21.0, hasBracelet: true, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1541030400), watchStatus: .available, accuracy: +1.0, accuracyMethod: .timeGrapher, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1704043200)], favorite: false),
            Watch(brand: "Audemars Piguet", model: "Royal Oak 15500ST", style: "Sport/Luxury", movement: "Automatic", caseDiameter: 41.0, lugWidth: 25.0, hasBracelet: true, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1514764800), watchStatus: .available, accuracy: -0.5, accuracyMethod: .timeGrapher, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1711363200)], favorite: false),
            Watch(brand: "IWC Schaffhausen", model: "Big Pilot 43", style: "Pilot", movement: "Automatic", caseDiameter: 43.0, lugWidth: 21.0, hasBracelet: false, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1635724800), watchStatus: .available, accuracy: +3.0, accuracyMethod: .manual, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1698796800)], favorite: false),
            Watch(brand: "Jaeger‑LeCoultre", model: "Reverso Classic", style: "Dress", movement: "Manual", caseDiameter: 42.9, lugWidth: 22.0, hasBracelet: false, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1483228800), watchStatus: .needsService, accuracy: nil, accuracyMethod: .other, dateHacked: nil, datesWorn: [], favorite: false),
            Watch(brand: "Panerai", model: "Luminor Marina PAM01312", style: "Diver", movement: "Automatic", caseDiameter: 44.0, lugWidth: 24.0, hasBracelet: false, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1604188800), watchStatus: .available, accuracy: -2.0, accuracyMethod: .timeGrapher, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1706659200)], favorite: false),
            Watch(brand: "Breitling", model: "Navitimer B01", style: "Pilot/Chronograph", movement: "Automatic Chronograph", caseDiameter: 43.0, lugWidth: 22.0, hasBracelet: true, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1577836800), watchStatus: .selling, accuracy: +5.0, accuracyMethod: .manual, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1696118400)], favorite: false),
            Watch(brand: "Tudor", model: "Black Bay Fifty-Eight", style: "Diver", movement: "Automatic", caseDiameter: 39.0, lugWidth: 20.0, hasBracelet: true, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1622505600), watchStatus: .available, accuracy: +2.0, accuracyMethod: .timeGrapher, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1709475200)], favorite: false),
            Watch(brand: "Hublot", model: "Big Bang Unico", style: "Sport/Luxury", movement: "Automatic Chronograph", caseDiameter: 44.0, lugWidth: 22.0, hasBracelet: false, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1506816000), watchStatus: .inRepair, accuracy: nil, accuracyMethod: .other, dateHacked: nil, datesWorn: [], favorite: false),
            Watch(brand: "Cartier", model: "Santos de Cartier", style: "Dress/Sport", movement: "Automatic", caseDiameter: 39.8, lugWidth: 20.0, hasBracelet: true, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1491004800), watchStatus: .available, accuracy: +1.5, accuracyMethod: .timeGrapher, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1701417600)], favorite: false),
            Watch(brand: "Vacheron Constantin", model: "Overseas 4500V", style: "Sport/Luxury", movement: "Automatic", caseDiameter: 41.0, lugWidth: 22.0, hasBracelet: true, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1451606400), watchStatus: .available, accuracy: -0.8, accuracyMethod: .timeGrapher, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1710288000)], favorite: false),
            Watch(brand: "Zenith", model: "El Primero 3600", style: "Chronograph", movement: "Automatic Chronograph", caseDiameter: 38.0, lugWidth: 20.0, hasBracelet: false, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1527811200), watchStatus: .available, accuracy: +0.7, accuracyMethod: .timeGrapher, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1699852800)], favorite: false),
            Watch(brand: "Bulgari", model: "Octo Finissimo Automatic", style: "Dress/Sport", movement: "Automatic", caseDiameter: 40.0, lugWidth: 21.0, hasBracelet: true, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1564617600), watchStatus: .available, accuracy: +1.0, accuracyMethod: .manual, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1704043200)], favorite: false),
            Watch(brand: "Longines", model: "Master Collection L2.673.4", style: "Dress", movement: "Automatic", caseDiameter: 38.5, lugWidth: 19.0, hasBracelet: false, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1585699200), watchStatus: .available, accuracy: +3.5, accuracyMethod: .manual, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1708684800)], favorite: false),
            Watch(brand: "Timex", model: "Marlin Automatic", style: "Dress/Vintage", movement: "Automatic", caseDiameter: 40.0, lugWidth: 20.0, hasBracelet: false, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1517443200), watchStatus: .available, accuracy: +20.0, accuracyMethod: .manual, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1693526400)], favorite: true),
            Watch(brand: "Citizen", model: "Promaster Diver NY0084-89E", style: "Diver", movement: "Automatic", caseDiameter: 42.0, lugWidth: 20.0, hasBracelet: true, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1630454400), watchStatus: .available, accuracy: +6.0, accuracyMethod: .manual, dateHacked: nil, datesWorn: [Date(timeIntervalSince1970: 1709475200)], favorite: true),
            Watch(brand: "Dan Henry", model: "1970 Automatic Diver", style: "Diver (Vintage)", movement: "Automatic", caseDiameter: 41.0, lugWidth: 20.0, hasBracelet: false, lastBatteryChange: nil, lastServiced: Date(timeIntervalSince1970: 1543622400), watchStatus: .selling, accuracy: +10.0, accuracyMethod: .manual, dateHacked: nil, datesWorn: [], favorite: true)
        ]
    }
}
