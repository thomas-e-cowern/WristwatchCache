//
//  IdealTextColorTests.swift
//  WristwatchCacheTests
//

import Testing
import SwiftUI
@testable import WristwatchCache

@MainActor
@Suite("Color idealTextColor Tests")
struct IdealTextColorTests {

    // MARK: - Light backgrounds should return black text

    @Test("White returns black text")
    func whiteReturnsBlack() {
        #expect(Color.white.idealTextColor == .black)
    }

    @Test("Yellow returns black text")
    func yellowReturnsBlack() {
        #expect(Color.yellow.idealTextColor == .black)
    }

    @Test("System cyan returns white text")
    func cyanReturnsWhite() {
        #expect(Color.cyan.idealTextColor == .white)
    }

    @Test("System green returns white text")
    func greenReturnsWhite() {
        #expect(Color.green.idealTextColor == .white)
    }

    // MARK: - Dark backgrounds should return white text

    @Test("Black returns white text")
    func blackReturnsWhite() {
        #expect(Color.black.idealTextColor == .white)
    }

    @Test("Dark blue returns white text")
    func blueReturnsWhite() {
        #expect(Color.blue.idealTextColor == .white)
    }

    @Test("Purple returns white text")
    func purpleReturnsWhite() {
        #expect(Color.purple.idealTextColor == .white)
    }

    // MARK: - Custom RGB values

    @Test("Bright custom color returns black text")
    func brightCustomReturnsBlack() {
        let bright = Color(red: 0.9, green: 0.9, blue: 0.9)
        #expect(bright.idealTextColor == .black)
    }

    @Test("Dark custom color returns white text")
    func darkCustomReturnsWhite() {
        let dark = Color(red: 0.1, green: 0.1, blue: 0.1)
        #expect(dark.idealTextColor == .white)
    }

    @Test("Red returns white text due to low perceived luminance")
    func redReturnsWhite() {
        let red = Color(red: 1.0, green: 0.0, blue: 0.0)
        #expect(red.idealTextColor == .white)
    }

    // MARK: - Consistency

    @Test("Same color always returns the same result")
    func consistentResult() {
        let color = Color.orange
        let first = color.idealTextColor
        let second = color.idealTextColor
        #expect(first == second)
    }

    @Test("Result is always black or white")
    func resultIsBinaryChoice() {
        let colors: [Color] = [.red, .green, .blue, .yellow, .orange, .purple, .brown, .cyan, .mint, .pink, .indigo, .teal, .white, .black, .gray]
        for color in colors {
            let result = color.idealTextColor
            #expect(result == .black || result == .white)
        }
    }
}
