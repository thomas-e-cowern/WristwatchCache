//
//  AddWatchButton.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 3/31/26.
//

import SwiftUI

struct AddWatchButton: View {
    @State private var showAddWatch = false

    var body: some View {
        Button {
            showAddWatch = true
        } label: {
            Image(systemName: "plus")
        }
        .accessibilityLabel("Add Watch")
        .accessibilityHint("Opens the add watch form")
        .sheet(isPresented: $showAddWatch) {
            AddWatchView()
        }
    }
}
