//
//  AppTips.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 4/21/26.
//

import TipKit

struct RandomPickerTip: Tip {
    var title: Text {
        Text("Smart Random Picker")
    }
    var message: Text? {
        Text("Filter by style or movement type, then get a random suggestion from your available watches. Tap \"Pick Again\" to reroll in the same category.")
    }
    var image: Image? {
        Image(systemName: "dice")
    }
}

struct WearPatternsTip: Tip {
    var title: Text {
        Text("Understanding Your Patterns")
    }
    var message: Text? {
        Text("Active Rotation counts distinct watches worn in the past 30 days. Current Streak tracks consecutive days wearing the same watch.")
    }
    var image: Image? {
        Image(systemName: "chart.bar.fill")
    }
}

struct RecurringOccasionTip: Tip {
    var title: Text {
        Text("Recurring Occasions")
    }
    var message: Text? {
        Text("Occasions can repeat weekly, biweekly, monthly, or annually — perfect for traditions like \"Blue Watch Monday\" or a service anniversary.")
    }
    var image: Image? {
        Image(systemName: "arrow.clockwise")
    }
}
