//
//  WristwatchCacheApp.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 3/30/26.
//

import SwiftUI
import SwiftData

@main
struct WristwatchCacheApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var container: ModelContainer = {
        do {
            return try ModelContainer(for: Watch.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task {
                    await handleBecameActive()
                }
            }
        }
    }

    private func handleBecameActive() async {
        await NotificationManager.requestPermission()

        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Watch>()
        let watches = (try? context.fetch(descriptor)) ?? []
        await NotificationManager.scheduleUnwornReminders(for: watches)
    }
}
