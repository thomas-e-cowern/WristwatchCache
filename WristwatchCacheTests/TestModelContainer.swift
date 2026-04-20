//
//  TestModelContainer.swift
//  WristwatchCacheTests
//
//  Created by Thomas Cowern on 4/1/26.
//

import Foundation
import SwiftData
import Testing
@testable import WristwatchCache

@MainActor
enum TestModelContainer {
    /// Creates a fresh in-memory ModelContainer for Watch and SpecialOccasion.
    static func make() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: Watch.self, SpecialOccasion.self, configurations: config)
    }

    /// Creates a container pre-populated with the given watches.
    static func makeWith(_ watches: [Watch]) throws -> ModelContainer {
        let container = try make()
        for watch in watches {
            container.mainContext.insert(watch)
        }
        try container.mainContext.save()
        return container
    }

    /// Creates a container pre-populated with sample data.
    static func makeWithSampleData() throws -> ModelContainer {
        try makeWith(Watch.sampleData)
    }
}
