//
//  WatchModelTests.swift
//  WristwatchCacheTests
//
//  Created by Thomas Cowern on 4/1/26.
//

import Testing
import Foundation
import SwiftData
@testable import WristwatchCache

@MainActor
@Suite("Watch Model Tests")
struct WatchModelTests {

    // MARK: - Initialization

    @Test("Watch initializes with all required properties and correct defaults")
    func initWithRequiredProperties() {
        let watch = Watch(
            brand: "Rolex",
            model: "Submariner",
            style: .diver,
            movement: .automatic,
            hasBracelet: true,
            watchStatus: .available,
            accuracyMethod: .manual,
            datesWorn: []
        )
        #expect(watch.brand == "Rolex")
        #expect(watch.model == "Submariner")
        #expect(watch.style == .diver)
        #expect(watch.movement == .automatic)
        #expect(watch.serialNumber == "N/A")
        #expect(watch.caseDiameter == nil)
        #expect(watch.lugWidth == nil)
        #expect(watch.hasBracelet == true)
        #expect(watch.watchStatus == .available)
        #expect(watch.accuracy == nil)
        #expect(watch.accuracyMethod == .manual)
        #expect(watch.dateHacked == nil)
        #expect(watch.datesWorn.isEmpty)
        #expect(watch.photo == nil)
        #expect(watch.favorite == false)
    }

    @Test("Watch initializes with all optional properties")
    func initWithAllProperties() {
        let now = Date()
        let photoData = Data([0x89, 0x50, 0x4E, 0x47])
        let watch = Watch(
            brand: "Omega",
            model: "Speedmaster",
            style: .chronograph,
            movement: .automatic,
            serialNumber: "ABC123",
            caseDiameter: 42.0,
            lugWidth: 20.0,
            hasBracelet: true,
            lastBatteryChange: now,
            lastServiced: now,
            watchStatus: .inService,
            accuracy: 2.5,
            accuracyMethod: .timeGrapher,
            dateHacked: now,
            datesWorn: [now],
            photo: photoData,
            favorite: true
        )
        #expect(watch.serialNumber == "ABC123")
        #expect(watch.caseDiameter == 42.0)
        #expect(watch.lugWidth == 20.0)
        #expect(watch.lastBatteryChange == now)
        #expect(watch.lastServiced == now)
        #expect(watch.accuracy == 2.5)
        #expect(watch.dateHacked == now)
        #expect(watch.datesWorn.count == 1)
        #expect(watch.photo == photoData)
        #expect(watch.favorite == true)
    }

    @Test("Watch initializes with custom serial number")
    func initWithSerialNumber() {
        let watch = Watch(
            brand: "Rolex", model: "Sub",
            style: .diver, movement: .automatic,
            serialNumber: "SN-12345-XYZ",
            hasBracelet: true, watchStatus: .available,
            accuracyMethod: .manual, datesWorn: []
        )
        #expect(watch.serialNumber == "SN-12345-XYZ")
    }

    @Test("Watch initializes with negative accuracy")
    func initWithNegativeAccuracy() {
        let watch = Watch(
            brand: "Rolex", model: "Sub",
            style: .diver, movement: .automatic,
            hasBracelet: true, watchStatus: .available,
            accuracy: -3.5,
            accuracyMethod: .timeGrapher, datesWorn: []
        )
        #expect(watch.accuracy == -3.5)
    }

    @Test("Watch initializes with each style enum value")
    func initWithVariousStyles() {
        for style in Style.allCases {
            let watch = Watch(
                brand: "Test", model: "Watch",
                style: style, movement: .automatic,
                hasBracelet: false, watchStatus: .available,
                accuracyMethod: .manual, datesWorn: []
            )
            #expect(watch.style == style)
        }
    }

    @Test("Watch initializes with each movement enum value")
    func initWithVariousMovements() {
        for movement in Movement.allCases {
            let watch = Watch(
                brand: "Test", model: "Watch",
                style: .dress, movement: movement,
                hasBracelet: false, watchStatus: .available,
                accuracyMethod: .manual, datesWorn: []
            )
            #expect(watch.movement == movement)
        }
    }

    // MARK: - SwiftData Persistence

    @Test("Watch persists to in-memory container and can be fetched")
    func persistAndFetch() throws {
        let container = try TestModelContainer.make()
        let context = container.mainContext

        let watch = Watch(
            brand: "Tudor", model: "Black Bay",
            style: .diver, movement: .automatic,
            hasBracelet: true, watchStatus: .available,
            accuracyMethod: .manual, datesWorn: []
        )
        context.insert(watch)
        try context.save()

        let descriptor = FetchDescriptor<Watch>()
        let fetched = try context.fetch(descriptor)
        #expect(fetched.count == 1)
        #expect(fetched.first?.brand == "Tudor")
        #expect(fetched.first?.model == "Black Bay")
    }

    @Test("Watch properties can be updated and saved")
    func updateProperties() throws {
        let container = try TestModelContainer.make()
        let context = container.mainContext

        let watch = Watch(
            brand: "Seiko", model: "SKX007",
            style: .diver, movement: .automatic,
            hasBracelet: true, watchStatus: .available,
            accuracyMethod: .manual, datesWorn: []
        )
        context.insert(watch)
        try context.save()

        watch.brand = "Grand Seiko"
        watch.model = "Snowflake"
        watch.favorite = true
        watch.watchStatus = .needsService
        watch.style = .dress
        watch.movement = .springDrive
        try context.save()

        let descriptor = FetchDescriptor<Watch>()
        let fetched = try context.fetch(descriptor)
        #expect(fetched.first?.brand == "Grand Seiko")
        #expect(fetched.first?.model == "Snowflake")
        #expect(fetched.first?.favorite == true)
        #expect(fetched.first?.watchStatus == .needsService)
        #expect(fetched.first?.style == .dress)
        #expect(fetched.first?.movement == .springDrive)
    }

    @Test("Watch can be deleted from context")
    func deleteWatch() throws {
        let container = try TestModelContainer.make()
        let context = container.mainContext

        let watch = Watch(
            brand: "Timex", model: "Marlin",
            style: .dress, movement: .automatic,
            hasBracelet: false, watchStatus: .available,
            accuracyMethod: .manual, datesWorn: []
        )
        context.insert(watch)
        try context.save()

        context.delete(watch)
        try context.save()

        let descriptor = FetchDescriptor<Watch>()
        let fetched = try context.fetch(descriptor)
        #expect(fetched.isEmpty)
    }

    @Test("Dates worn array can be appended to and persisted")
    func appendDatesWorn() throws {
        let container = try TestModelContainer.make()
        let context = container.mainContext

        let watch = Watch(
            brand: "Citizen", model: "Promaster",
            style: .diver, movement: .automatic,
            hasBracelet: true, watchStatus: .available,
            accuracyMethod: .manual, datesWorn: []
        )
        context.insert(watch)
        try context.save()

        watch.datesWorn.append(Date())
        watch.datesWorn.append(Date())
        try context.save()

        let descriptor = FetchDescriptor<Watch>()
        let fetched = try context.fetch(descriptor)
        #expect(fetched.first?.datesWorn.count == 2)
    }

    @Test("Favorite can be toggled and persisted")
    func toggleFavorite() throws {
        let container = try TestModelContainer.make()
        let context = container.mainContext

        let watch = Watch(
            brand: "Omega", model: "Speedmaster",
            style: .chronograph, movement: .automatic,
            hasBracelet: true, watchStatus: .available,
            accuracyMethod: .manual, datesWorn: [],
            favorite: false
        )
        context.insert(watch)
        try context.save()
        #expect(watch.favorite == false)

        watch.favorite = true
        try context.save()

        let descriptor = FetchDescriptor<Watch>()
        let fetched = try context.fetch(descriptor)
        #expect(fetched.first?.favorite == true)
    }

    @Test("Style and movement enums persist through SwiftData")
    func enumPersistence() throws {
        let container = try TestModelContainer.make()
        let context = container.mainContext

        let watch = Watch(
            brand: "IWC", model: "Big Pilot",
            style: .pilot, movement: .handWound,
            hasBracelet: false, watchStatus: .inService,
            accuracyMethod: .timeGrapher, datesWorn: []
        )
        context.insert(watch)
        try context.save()

        let descriptor = FetchDescriptor<Watch>()
        let fetched = try context.fetch(descriptor)
        #expect(fetched.first?.style == .pilot)
        #expect(fetched.first?.movement == .handWound)
        #expect(fetched.first?.watchStatus == .inService)
        #expect(fetched.first?.accuracyMethod == .timeGrapher)
    }

    @Test("Multiple watches can be inserted and fetched")
    func multipleWatches() throws {
        let container = try TestModelContainer.make()
        let context = container.mainContext

        for i in 1...5 {
            let watch = Watch(
                brand: "Brand\(i)", model: "Model\(i)",
                style: .dress, movement: .automatic,
                hasBracelet: false, watchStatus: .available,
                accuracyMethod: .manual, datesWorn: []
            )
            context.insert(watch)
        }
        try context.save()

        let descriptor = FetchDescriptor<Watch>()
        let fetched = try context.fetch(descriptor)
        #expect(fetched.count == 5)
    }

    // MARK: - Sample Data

    @Test("Sample data contains 20 watches")
    func sampleDataCount() {
        #expect(Watch.sampleData.count == 20)
    }

    @Test("Sample data watches have non-empty brand and model")
    func sampleDataNonEmpty() {
        for watch in Watch.sampleData {
            #expect(!watch.brand.isEmpty)
            #expect(!watch.model.isEmpty)
        }
    }

    @Test("Sample data loads into SwiftData container")
    func sampleDataLoads() throws {
        let container = try TestModelContainer.makeWithSampleData()
        let descriptor = FetchDescriptor<Watch>()
        let fetched = try container.mainContext.fetch(descriptor)
        #expect(fetched.count == 20)
    }

    @Test("Sample data contains watches with favorites")
    func sampleDataHasFavorites() {
        let favorites = Watch.sampleData.filter { $0.favorite }
        #expect(favorites.count > 0)
    }

    @Test("Sample data contains watches with various statuses")
    func sampleDataHasVariousStatuses() {
        let statuses = Set(Watch.sampleData.map { $0.watchStatus })
        #expect(statuses.count > 1)
    }
}
