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

    // MARK: - initials(for:)

    @Test("Single word brand returns first character uppercased")
    func singleWordInitials() {
        #expect(BrandView.initials(for: "Rolex") == "R")
        #expect(BrandView.initials(for: "Omega") == "O")
        #expect(BrandView.initials(for: "Tudor") == "T")
    }

    @Test("Two word brand returns two initials")
    func twoWordInitials() {
        #expect(BrandView.initials(for: "Grand Seiko") == "GS")
        #expect(BrandView.initials(for: "TAG Heuer") == "TH")
        #expect(BrandView.initials(for: "Dan Henry") == "DH")
        #expect(BrandView.initials(for: "Patek Philippe") == "PP")
    }

    @Test("Three or more word brand caps at 3 initials")
    func threeWordMax() {
        #expect(BrandView.initials(for: "Oak & Oscar") == "O&O")
        #expect(BrandView.initials(for: "Alpha Beta Gamma Delta") == "ABG")
    }

    @Test("Hyphenated brand splits on hyphen")
    func hyphenatedInitials() {
        #expect(BrandView.initials(for: "Jaeger-LeCoultre") == "JL")
    }

    @Test("Non-breaking hyphen brand splits correctly")
    func nonBreakingHyphenInitials() {
        let brand = "Jaeger\u{2011}LeCoultre"
        #expect(BrandView.initials(for: brand) == "JL")
    }

    @Test("Initials are always uppercased")
    func initialsUppercased() {
        #expect(BrandView.initials(for: "lowercase brand") == "LB")
    }

    // MARK: - brandColor(for:)

    @Test("Known non-black brands return non-black colors")
    func knownBrandsReturnColor() {
        // Breitling is yellow, Swatch is orange, Farer is orange -- all clearly not black
        #expect(BrandView.brandColor(for: "Breitling") != Color.black)
        #expect(BrandView.brandColor(for: "Swatch") != Color.black)
        #expect(BrandView.brandColor(for: "Farer") != Color.black)
    }

    @Test("Unknown brand returns black")
    func unknownBrandReturnsBlack() {
        #expect(BrandView.brandColor(for: "UnknownBrandXYZ") == Color.black)
    }

    @Test("Empty string brand returns black")
    func emptyBrandReturnsBlack() {
        #expect(BrandView.brandColor(for: "") == Color.black)
    }

    @Test("Brand color lookup is case-sensitive")
    func caseSensitiveLookup() {
        #expect(BrandView.brandColor(for: "rolex") == Color.black)
    }
}
