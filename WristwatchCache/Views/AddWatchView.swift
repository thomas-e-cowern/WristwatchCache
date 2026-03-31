//
//  AddWatchView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 3/31/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddWatchView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // Basic info
    @State private var brand: String = ""
    @State private var modelName: String = ""
    @State private var style: String = ""
    @State private var movement: String = ""

    // Size
    @State private var caseDiameterText: String = ""
    @State private var lugWidthText: String = ""

    // Bracelet
    @State private var hasBracelet: Bool = false

    // Service
    @State private var lastBatteryChange: Date? = nil
    @State private var lastServiced: Date? = nil
    @State private var showBatteryPicker: Bool = false
    @State private var showServicePicker: Bool = false

    // Status & accuracy
    @State private var watchStatus: WatchStatus = .available
    @State private var accuracyText: String = ""
    @State private var accuracyMethod: AccuracyMethod = .manual

    // Date hacked & wear
    @State private var dateHacked: Date? = nil
    @State private var showDateHackedPicker = false
    @State private var datesWorn: [Date] = []

    // Photo (externalStorage)
    @State private var photoData: Data? = nil
    @State private var photosPickerItems: [PhotosPickerItem] = []

    // Favorite
    @State private var favorite: Bool = false

    // Validation
    private var isValid: Bool {
        !brand.trimmingCharacters(in: .whitespaces).isEmpty &&
        !modelName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic") {
                    TextField("Brand", text: $brand)
                    TextField("Model", text: $modelName)
                    TextField("Style", text: $style)
                    TextField("Movement", text: $movement)
                }

                Section("Size") {
                    TextField("Case diameter (mm)", text: $caseDiameterText)
                        .keyboardType(.decimalPad)
                    TextField("Lug width (mm)", text: $lugWidthText)
                        .keyboardType(.decimalPad)
                    Toggle("Has bracelet", isOn: $hasBracelet)
                }

                Section("Service") {
                    Toggle("Set last battery change", isOn: $showBatteryPicker.animation())
                    if showBatteryPicker {
                        DatePicker("Last battery change", selection: Binding(get: { lastBatteryChange ?? Date() }, set: { lastBatteryChange = $0 }), displayedComponents: .date)
                    }

                    Toggle("Set last serviced", isOn: $showServicePicker.animation())
                    if showServicePicker {
                        DatePicker("Last serviced", selection: Binding(get: { lastServiced ?? Date() }, set: { lastServiced = $0 }), displayedComponents: .date)
                    }
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
                    Toggle("Date hacked (set)", isOn: $showDateHackedPicker.animation())
                    if showDateHackedPicker {
                        DatePicker("Date hacked", selection: Binding(get: { dateHacked ?? Date() }, set: { dateHacked = $0 }), displayedComponents: .date)
                    }
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

                Section("Photo") {
                    PhotosPicker(selection: $photosPickerItems, matching: .images, photoLibrary: .shared()) {
                        HStack {
                            Text("Select photo")
                            Spacer()
                            if photoData != nil {
                                Image(uiImage: UIImage(data: photoData!)!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 44, height: 44)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                        }
                    }
                    .onChange(of: photosPickerItems) {
                        guard let item = photosPickerItems.first else { return }
                        Task {
                            if let data = try? await item.loadTransferable(type: Data.self) {
                                await MainActor.run { photoData = data }
                            }
                        }
                    }
                }

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
            style: style.trimmingCharacters(in: .whitespaces),
            movement: movement.trimmingCharacters(in: .whitespaces),
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
