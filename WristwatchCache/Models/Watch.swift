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
