//
//  SpecialOccasion.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 4/20/26.
//

import Foundation
import SwiftData

@Model
class SpecialOccasion {
    var name: String
    var date: Date
    var notes: String
    var watch: Watch?

    init(name: String, date: Date, notes: String = "", watch: Watch? = nil) {
        self.name = name
        self.date = date
        self.notes = notes
        self.watch = watch
    }
}
