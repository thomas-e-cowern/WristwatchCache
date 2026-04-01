//
//  AddWatchValidationTests.swift
//  WristwatchCacheTests
//
//  Created by Thomas Cowern on 4/1/26.
//

import Testing
import Foundation
@testable import WristwatchCache

@Suite("Watch Validation Tests")
struct AddWatchValidationTests {

    @Test("Valid when both brand and model are non-empty")
    func validBrandAndModel() {
        #expect(Watch.isValid(brand: "Rolex", model: "Submariner") == true)
    }

    @Test("Invalid when brand is empty")
    func emptyBrand() {
        #expect(Watch.isValid(brand: "", model: "Submariner") == false)
    }

    @Test("Invalid when model is empty")
    func emptyModel() {
        #expect(Watch.isValid(brand: "Rolex", model: "") == false)
    }

    @Test("Invalid when both are empty")
    func bothEmpty() {
        #expect(Watch.isValid(brand: "", model: "") == false)
    }

    @Test("Invalid when brand is only whitespace")
    func whitespaceOnlyBrand() {
        #expect(Watch.isValid(brand: "   ", model: "Submariner") == false)
    }

    @Test("Invalid when model is only whitespace")
    func whitespaceOnlyModel() {
        #expect(Watch.isValid(brand: "Rolex", model: "   ") == false)
    }

    @Test("Valid when brand and model have leading/trailing spaces but contain text")
    func trimmedValid() {
        #expect(Watch.isValid(brand: "  Rolex  ", model: "  Sub  ") == true)
    }

    @Test("Valid with single character brand and model")
    func singleChar() {
        #expect(Watch.isValid(brand: "R", model: "S") == true)
    }
}
