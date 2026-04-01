//
//  WatchDetailView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 3/31/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct WatchDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var watch: Watch

    // Editable copies of fields
    @State private var brand: String
    @State private var modelName: String
    @State private var style: Style
    @State private var movement: Movement

    @State private var caseDiameterText: String
    @State private var lugWidthText: String

    @State private var hasBracelet: Bool

    @State private var lastBatteryChange: Date?
    @State private var lastServiced: Date?
    @State private var showBatteryPicker: Bool = false
    @State private var showServicePicker: Bool = false

    @State private var watchStatus: WatchStatus
    @State private var accuracyText: String
    @State private var accuracyMethod: AccuracyMethod

    @State private var dateHacked: Date?
    @State private var showDateHackedPicker: Bool = false

    @State private var datesWorn: [Date]

    @State private var photoData: Data?
    @State private var photosPickerItems: [PhotosPickerItem] = []
    @State private var showCamera = false

    @State private var favorite: Bool

    // Init uses the passed watch to prefill state
    init(watch: Watch) {
        self.watch = watch
        _brand = State(initialValue: watch.brand)
        _modelName = State(initialValue: watch.model)
        _style = State(initialValue: watch.style)
        _movement = State(initialValue: watch.movement)
        _caseDiameterText = State(initialValue: watch.caseDiameter.map { String($0) } ?? "")
        _lugWidthText = State(initialValue: watch.lugWidth.map { String($0) } ?? "")
        _hasBracelet = State(initialValue: watch.hasBracelet)
        _lastBatteryChange = State(initialValue: watch.lastBatteryChange)
        _lastServiced = State(initialValue: watch.lastServiced)
        _watchStatus = State(initialValue: watch.watchStatus)
        _accuracyText = State(initialValue: watch.accuracy.map { String($0) } ?? "")
        _accuracyMethod = State(initialValue: watch.accuracyMethod)
        _dateHacked = State(initialValue: watch.dateHacked)
        _datesWorn = State(initialValue: watch.datesWorn)
        _photoData = State(initialValue: watch.photo)
        _favorite = State(initialValue: watch.favorite)
    }

    private var isValid: Bool {
        Watch.isValid(brand: brand, model: modelName)
    }

    var body: some View {
        Form {
            Section("Basic") {
                TextField("Brand", text: $brand)
                TextField("Model", text: $modelName)
                Picker("Style", selection: $style) {
                    ForEach(Style.allCases, id: \.self) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                Picker("Movement", selection: $movement) {
                    ForEach(Movement.allCases, id: \.self) { movement in
                        Text(movement.rawValue).tag(movement)
                    }
                }
            }

            Section("Size") {
                TextField("Case diameter (mm)", text: $caseDiameterText)
                    .keyboardType(.decimalPad)
                TextField("Lug width (mm)", text: $lugWidthText)
                    .keyboardType(.decimalPad)
                Toggle("Has bracelet", isOn: $hasBracelet)
            }

            Section("Service") {
                Toggle("Set last battery change", isOn: Binding(
                    get: { lastBatteryChange != nil },
                    set: { newValue in
                        showBatteryPicker = newValue
                        if newValue && lastBatteryChange == nil { lastBatteryChange = Date() }
                        if !newValue { lastBatteryChange = nil }
                    }
                ))
                if showBatteryPicker || lastBatteryChange != nil {
                    DatePicker("Last battery change", selection: Binding(
                        get: { lastBatteryChange ?? Date() },
                        set: { lastBatteryChange = $0 }
                    ), displayedComponents: .date)
                }

                Toggle("Set last serviced", isOn: Binding(
                    get: { lastServiced != nil },
                    set: { newValue in
                        showServicePicker = newValue
                        if newValue && lastServiced == nil { lastServiced = Date() }
                        if !newValue { lastServiced = nil }
                    }
                ))
                if showServicePicker || lastServiced != nil {
                    DatePicker("Last serviced", selection: Binding(
                        get: { lastServiced ?? Date() },
                        set: { lastServiced = $0 }
                    ), displayedComponents: .date)
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
                Toggle("Date hacked (set)", isOn: Binding(
                    get: { dateHacked != nil },
                    set: { newValue in
                        showDateHackedPicker = newValue
                        if newValue && dateHacked == nil { dateHacked = Date() }
                        if !newValue { dateHacked = nil }
                    }
                ))
                if showDateHackedPicker || dateHacked != nil {
                    DatePicker("Date hacked", selection: Binding(
                        get: { dateHacked ?? Date() },
                        set: { dateHacked = $0 }
                    ), displayedComponents: .date)
                }
            }

            Section("Wear history") {
                ForEach(datesWorn.indices, id: \.self) { idx in
                    DatePicker("Worn \(idx+1)", selection: Binding(
                        get: { datesWorn[idx] },
                        set: { datesWorn[idx] = $0 }
                    ), displayedComponents: .date)
                }
                Button("Add wear date") { datesWorn.append(Date()) }
                    .buttonStyle(.bordered)
                if !datesWorn.isEmpty {
                    Button("Clear wear dates", role: .destructive) { datesWorn.removeAll() }
                }
            }

            Section("Photo") {
                if let data = photoData, let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                PhotosPicker(selection: $photosPickerItems, matching: .images) {
                    Label("Choose from Library", systemImage: "photo.on.rectangle")
                }
                .onChange(of: photosPickerItems) {
                    guard let item = photosPickerItems.first else { return }
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            await MainActor.run { photoData = data }
                        }
                    }
                }

                Button {
                    showCamera = true
                } label: {
                    Label("Take Photo", systemImage: "camera")
                }
                .sheet(isPresented: $showCamera) {
                    CameraPicker { data in
                        photoData = data
                    }
                    .ignoresSafeArea()
                }

                if photoData != nil {
                    Button("Remove Photo", role: .destructive) { photoData = nil }
                }
            }

            Section {
                Toggle("Favorite", isOn: $favorite)
            }

            Section {
                Button("Save") {
                    saveChanges()
                }
                .disabled(!isValid)

                Button("Delete", role: .destructive) {
                    deleteWatch()
                }
            }
        }
        .navigationTitle("\(watch.brand) \(watch.model)")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func saveChanges() {
        // Apply edits back to the ObservedObject and save
        watch.brand = brand.trimmingCharacters(in: .whitespaces)
        watch.model = modelName.trimmingCharacters(in: .whitespaces)
        watch.style = style
        watch.movement = movement
        watch.caseDiameter = Double(caseDiameterText)
        watch.lugWidth = Double(lugWidthText)
        watch.hasBracelet = hasBracelet
        watch.lastBatteryChange = lastBatteryChange
        watch.lastServiced = lastServiced
        watch.watchStatus = watchStatus
        watch.accuracy = Double(accuracyText)
        watch.accuracyMethod = accuracyMethod
        watch.dateHacked = dateHacked
        watch.datesWorn = datesWorn
        watch.photo = photoData
        watch.favorite = favorite

        do {
            try modelContext.save()
        } catch {
            print("Failed to save watch: \(error)")
        }
        dismiss()
    }

    private func deleteWatch() {
        modelContext.delete(watch)
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete watch: \(error)")
        }
        dismiss()
    }
}

#Preview {
    let preview = PreviewContainer(Watch.self)
    preview.addSamples(Watch.sampleData)
    return NavigationStack {
        WatchDetailView(watch: Watch.sampleData.first!)
    }
    .modelContainer(preview.container)
}
