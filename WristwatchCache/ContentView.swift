//
//  ContentView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 3/30/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext) var modelContext
    
    @Query var watches: [Watch]
    
    var body: some View {
        VStack {
            List {
                ForEach(watches) { watch in
                    HStack {
                        Text(watch.brand)
                            .font(.title)
                            .foregroundColor(.white) // Color of the text
                            .padding(20) // Adds space between text and circle
                            .background(Color.blue) // Color of the circle
                            .clipShape(Circle()) // Clips the background color to a circle shape
                        Text(watch.model)
                            .font(.headline)
                    }
                }
            }
        }
    }
}

#Preview {
    let preview = Preview(Watch.self)
    preview.addSamples(Watch.sampleData)
    return ContentView()
        .modelContainer(preview.container)
}

import Foundation
import SwiftData

struct Preview {
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
    
    func addSamples(_ watches: [Watch]) {
        Task { @MainActor in
            watches.forEach { watch in
                container.mainContext.insert(watch)
            }
        }
    }
}
