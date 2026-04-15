//
//  RandomPickerView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 4/15/26.
//

import SwiftUI

struct RandomPickerView: View {
    let watches: [Watch]
    let onSelectWatch: (Watch) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var filterMode: FilterMode?
    @State private var pickedWatch: Watch?

    private var availableWatches: [Watch] {
        watches.filter { $0.watchStatus == .available }
    }

    /// Styles that actually exist in the user's available collection
    private var availableStyles: [Style] {
        let styles = Set(availableWatches.map(\.style))
        return Style.allCases.filter { styles.contains($0) }
    }

    /// Movements that actually exist in the user's available collection
    private var availableMovements: [Movement] {
        let movements = Set(availableWatches.map(\.movement))
        return Movement.allCases.filter { movements.contains($0) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if let watch = pickedWatch {
                    resultView(watch)
                } else if let mode = filterMode {
                    filterListView(mode)
                } else {
                    modeSelectionView
                }
            }
            .navigationTitle("Pick a Watch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Step 1: Choose filter mode

    private var modeSelectionView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "dice")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("I would like to wear a...")
                .font(.title2.bold())

            VStack(spacing: 12) {
                Button {
                    filterMode = .style
                } label: {
                    Label("Pick by Style", systemImage: "paintpalette")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    filterMode = .movement
                } label: {
                    Label("Pick by Movement", systemImage: "gearshape.2")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Step 2: Choose specific style or movement

    private func filterListView(_ mode: FilterMode) -> some View {
        List {
            Section {
                Text(mode == .style
                     ? "Pick a style and we'll randomly choose a watch for you."
                     : "Pick a movement type and we'll randomly choose a watch for you.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section(mode == .style ? "Styles" : "Movements") {
                switch mode {
                case .style:
                    ForEach(availableStyles, id: \.self) { style in
                        let count = availableWatches.filter { $0.style == style }.count
                        Button {
                            pickRandom(style: style)
                        } label: {
                            HStack {
                                Circle()
                                    .fill(style.color)
                                    .frame(width: 10, height: 10)
                                Text(style.rawValue)
                                Spacer()
                                Text("\(count)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tint(.primary)
                    }
                case .movement:
                    ForEach(availableMovements, id: \.self) { movement in
                        let count = availableWatches.filter { $0.movement == movement }.count
                        Button {
                            pickRandom(movement: movement)
                        } label: {
                            HStack {
                                Circle()
                                    .fill(movement.color)
                                    .frame(width: 10, height: 10)
                                Text(movement.rawValue)
                                Spacer()
                                Text("\(count)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tint(.primary)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Back") {
                    filterMode = nil
                }
            }
        }
    }

    // MARK: - Step 3: Show the picked watch

    private func resultView(_ watch: Watch) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                CardView(
                    imageData: watch.photo,
                    brand: watch.brand,
                    model: watch.model,
                    showWearButton: false
                )
                .padding(.horizontal)

                VStack(spacing: 8) {
                    detailRow("Style", value: watch.style.rawValue)
                    detailRow("Movement", value: watch.movement.rawValue)
                    if let diameter = watch.caseDiameter {
                        detailRow("Case Size", value: "\(String(format: "%.0f", diameter))mm")
                    }
                }
                .padding(.horizontal)

                VStack(spacing: 12) {
                    Button {
                        onSelectWatch(watch)
                        dismiss()
                    } label: {
                        Label("Wear This Watch", systemImage: "checkmark.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        reroll()
                    } label: {
                        Label("Pick Again", systemImage: "dice")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }

    private func detailRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }

    // MARK: - Actions

    private func pickRandom(style: Style) {
        pickedWatch = availableWatches.filter { $0.style == style }.randomElement()
    }

    private func pickRandom(movement: Movement) {
        pickedWatch = availableWatches.filter { $0.movement == movement }.randomElement()
    }

    private func reroll() {
        guard let current = pickedWatch else { return }
        let candidates: [Watch]
        if let mode = filterMode {
            switch mode {
            case .style:
                candidates = availableWatches.filter { $0.style == current.style }
            case .movement:
                candidates = availableWatches.filter { $0.movement == current.movement }
            }
        } else {
            candidates = availableWatches
        }

        // Try to pick a different watch if possible
        if candidates.count > 1 {
            var next = current
            while next === current {
                next = candidates.randomElement()!
            }
            pickedWatch = next
        }
    }
}

// MARK: - Filter Mode

private enum FilterMode {
    case style
    case movement
}

#Preview {
    RandomPickerView(
        watches: Watch.sampleData,
        onSelectWatch: { _ in }
    )
}
