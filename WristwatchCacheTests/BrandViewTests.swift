//
//  BrandViewTests.swift
//  WristwatchCacheTests
//
//  Created by Thomas Cowern on 4/1/26.
//

import Testing
import SwiftUI
@testable import WristwatchCache

@MainActor
@Suite("BrandView Logic Tests")
struct BrandViewTests {

    private let view = BrandView(brand: "")

    // MARK: - initials(for:)

    @Test("Single word brand returns first character uppercased")
    func singleWordInitials() {
        #expect(view.initials(for: "Rolex") == "R")
        #expect(view.initials(for: "Omega") == "O")
        #expect(view.initials(for: "Tudor") == "T")
    }

    @Test("Two word brand returns two initials")
    func twoWordInitials() {
        #expect(view.initials(for: "Grand Seiko") == "GS")
        #expect(view.initials(for: "TAG Heuer") == "TH")
        #expect(view.initials(for: "Dan Henry") == "DH")
        #expect(view.initials(for: "Patek Philippe") == "PP")
    }

    @Test("Three or more word brand caps at 3 initials")
    func threeWordMax() {
        #expect(view.initials(for: "Oak & Oscar") == "O&O")
        #expect(view.initials(for: "Alpha Beta Gamma Delta") == "ABG")
    }

    @Test("Hyphenated brand splits on hyphen")
    func hyphenatedInitials() {
        #expect(view.initials(for: "Jaeger-LeCoultre") == "JL")
    }

    @Test("Non-breaking hyphen brand splits correctly")
    func nonBreakingHyphenInitials() {
        let brand = "Jaeger\u{2011}LeCoultre"
        #expect(view.initials(for: brand) == "JL")
    }

    @Test("Initials are always uppercased")
    func initialsUppercased() {
        #expect(view.initials(for: "lowercase brand") == "LB")
    }

    // MARK: - brandColor(for:)

    @Test("Known non-black brands return non-black colors")
    func knownBrandsReturnColor() {
        // Breitling is yellow, Swatch is orange, Farer is orange -- all clearly not black
        #expect(view.brandColor(for: "Breitling") != Color.black)
        #expect(view.brandColor(for: "Swatch") != Color.black)
        #expect(view.brandColor(for: "Farer") != Color.black)
    }

    @Test("Unknown brand returns black")
    func unknownBrandReturnsBlack() {
        #expect(view.brandColor(for: "UnknownBrandXYZ") == Color.black)
    }

    @Test("Empty string brand returns black")
    func emptyBrandReturnsBlack() {
        #expect(view.brandColor(for: "") == Color.black)
    }

    @Test("Brand color lookup is case-sensitive")
    func caseSensitiveLookup() {
        #expect(view.brandColor(for: "rolex") == Color.black)
    }
}
