//
//  PreviewContainer.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 3/31/26.
//

import Foundation
import SwiftData

struct PreviewContainer {
    let container: ModelContainer
    
    init(_ models: any PersistentModel.Type...) {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let schema = Schema(models)
        do {
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("The preview container couldn't be created")
        }
    }
    
    @MainActor
    func addSamples(_ watches: [Watch]) {
        watches.forEach { watch in
            container.mainContext.insert(watch)
        }
    }
}
