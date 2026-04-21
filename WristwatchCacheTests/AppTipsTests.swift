//
//  AppTipsTests.swift
//  WristwatchCacheTests
//
//  Created by Thomas Cowern on 4/21/26.
//

import Testing
import SwiftUI
import TipKit
@testable import WristwatchCache

@MainActor
@Suite("AppTips Tests")
struct AppTipsTests {

    // MARK: - RandomPickerTip

    @Test("RandomPickerTip has a non-nil message")
    func randomPickerTipHasMessage() {
        #expect(RandomPickerTip().message != nil)
    }

    @Test("RandomPickerTip has a non-nil image")
    func randomPickerTipHasImage() {
        #expect(RandomPickerTip().image != nil)
    }

    // MARK: - WearPatternsTip

    @Test("WearPatternsTip has a non-nil message")
    func wearPatternsTipHasMessage() {
        #expect(WearPatternsTip().message != nil)
    }

    @Test("WearPatternsTip has a non-nil image")
    func wearPatternsTipHasImage() {
        #expect(WearPatternsTip().image != nil)
    }

    // MARK: - RecurringOccasionTip

    @Test("RecurringOccasionTip has a non-nil message")
    func recurringOccasionTipHasMessage() {
        #expect(RecurringOccasionTip().message != nil)
    }

    @Test("RecurringOccasionTip has a non-nil image")
    func recurringOccasionTipHasImage() {
        #expect(RecurringOccasionTip().image != nil)
    }

    // MARK: - All tips fully configured

    @Test("All three tips have both a message and an image")
    func allTipsFullyConfigured() {
        let tips: [(message: (any View)?, image: Image?)] = [
            (RandomPickerTip().message,       RandomPickerTip().image),
            (WearPatternsTip().message,       WearPatternsTip().image),
            (RecurringOccasionTip().message,  RecurringOccasionTip().image),
        ]
        for tip in tips {
            #expect(tip.message != nil)
            #expect(tip.image   != nil)
        }
    }
}
