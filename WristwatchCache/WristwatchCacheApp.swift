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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Watch.self)
    }
}
