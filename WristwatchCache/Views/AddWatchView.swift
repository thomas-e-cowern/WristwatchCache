//
//  AddWatchView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 3/31/26.
//

import SwiftUI
import SwiftData

struct AddWatchView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // Basic info
    @State private var brand: String = ""
    @State private var modelName: String = ""
    @State private var style: Style = .dress
    @State private var movement: Movement = .automatic
    @State private var serialNumber: String = ""

    // Size
    @State private var caseDiameterText: String = ""
    @State private var lugWidthText: String = ""

    // Bracelet
    @State private var hasBracelet: Bool = false

    // Service
    @State private var lastBatteryChange: Date? = nil
    @State private var lastServiced: Date? = nil

    // Status & accuracy
    @State private var watchStatus: WatchStatus = .available
    @State private var accuracyText: String = ""
    @State private var accuracyMethod: AccuracyMethod = .manual

    // Date hacked & wear
    @State private var dateHacked: Date? = nil
    @State private var datesWorn: [Date] = []

    // Photo (externalStorage)
    @State private var photoData: Data? = nil

    // Favorite
    @State private var favorite: Bool = false

    private var isValid: Bool {
        Watch.isValid(brand: brand, model: modelName)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic") {
                    TextField("Brand", text: $brand)
                    TextField("Model", text: $modelName)

                    Picker("Style", selection: $style) {
                        ForEach(Style.allCases, id: \.self) { styleCase in
                            Text(styleCase.rawValue).tag(styleCase)
                        }
                    }

                    Picker("Movement", selection: $movement) {
                        ForEach(Movement.allCases, id: \.self) { movementCase in
                            Text(movementCase.rawValue).tag(movementCase)
                        }
                    }
                    TextField("Serial Number", text: $serialNumber)
                }

                Section("Size") {
                    TextField("Case diameter (mm)", text: $caseDiameterText)
                        .keyboardType(.decimalPad)
                    TextField("Lug width (mm)", text: $lugWidthText)
                        .keyboardType(.decimalPad)
                    Toggle("Has bracelet", isOn: $hasBracelet)
                }

                Section("Service") {
                    OptionalDatePickerRow(toggleLabel: "Set last battery change", pickerLabel: "Last battery change", date: $lastBatteryChange)
                    OptionalDatePickerRow(toggleLabel: "Set last serviced", pickerLabel: "Last serviced", date: $lastServiced)
                }

                Section("Status & Accuracy") {
                    Picker("Status", selection: $watchStatus) {
                        ForEach(WatchStatus.allCases, id: \.self) { status in
                            Text(status.rawValue.capitalized).tag(status)
                        }
                    }
                    TextField("Accuracy (s/day)", text: $accuracyText)
                        .keyboardType(.decimalPad)
                    Picker("Accuracy method", selection: $accuracyMethod) {
                        ForEach(AccuracyMethod.allCases, id: \.self) { method in
                            Text(method.rawValue.capitalized).tag(method)
                        }
                    }
                    OptionalDatePickerRow(toggleLabel: "Date hacked (set)", pickerLabel: "Date hacked", date: $dateHacked)
                }

                Section("Wear history") {
                    ForEach(datesWorn.indices, id: \.self) { idx in
                        DatePicker("Worn \(idx+1)", selection: Binding(get: {
                            datesWorn[idx]
                        }, set: {
                            datesWorn[idx] = $0
                        }), displayedComponents: .date)
                    }
                    Button("Add wear date") {
                        datesWorn.append(Date())
                    }
                    .buttonStyle(.bordered)
                    if !datesWorn.isEmpty {
                        Button("Clear wear dates", role: .destructive) {
                            datesWorn.removeAll()
                        }
                    }
                }

                PhotoPickerSection(photoData: $photoData)

                Section {
                    Toggle("Favorite", isOn: $favorite)
                }

                Section {
                    Button("Save") { save() }
                        .disabled(!isValid)
                }
            }
            .navigationTitle("Add Watch")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func save() {
        // Convert numeric fields
        let caseDiameter = Double(caseDiameterText)
        let lugWidth = Double(lugWidthText)
        let accuracy = Double(accuracyText)

        // Create Watch instance — adjust initializer if needed
        let newWatch = Watch(
            brand: brand.trimmingCharacters(in: .whitespaces),
            model: modelName.trimmingCharacters(in: .whitespaces),
            style: style,
            movement: movement,
            serialNumber: serialNumber.trimmingCharacters(in: .whitespaces),
            caseDiameter: caseDiameter,
            lugWidth: lugWidth,
            hasBracelet: hasBracelet,
            lastBatteryChange: lastBatteryChange,
            lastServiced: lastServiced,
            watchStatus: watchStatus,
            accuracy: accuracy,
            accuracyMethod: accuracyMethod,
            dateHacked: dateHacked,
            datesWorn: datesWorn,
            photo: photoData,
            favorite: favorite
        )

        modelContext.insert(newWatch)
        do {
            try modelContext.save()
        } catch {
            print("Save failed: \(error)")
        }

        dismiss()
    }
}


#Preview {
    AddWatchView()
}
