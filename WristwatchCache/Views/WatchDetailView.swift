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

    @State private var isEditing = false

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

    @State private var showDeleteConfirmation = false
    @State private var activeOccasionSheet: OccasionSheetMode?

    private enum OccasionSheetMode: Identifiable {
        case add
        case edit(SpecialOccasion)
        var id: String {
            switch self {
            case .add: return "add"
            case .edit(let o): return o.persistentModelID.hashValue.description
            }
        }
    }

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

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    var body: some View {
        Form {
            if isEditing {
                editView
            } else {
                displayView
            }
        }
        .navigationTitle("\(watch.brand) \(watch.model)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if isEditing {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(!isValid)
                } else {
                    Button("Edit") {
                        isEditing = true
                    }
                }
            }
            if isEditing {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        resetFields()
                        isEditing = false
                    }
                }
            }
        }
        .confirmationDialog("Delete this watch?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                deleteWatch()
            }
        }
        .sheet(item: $activeOccasionSheet) { mode in
            switch mode {
            case .add:
                AddEditSpecialOccasionView(preselectedWatch: watch)
            case .edit(let occasion):
                AddEditSpecialOccasionView(occasion: occasion)
            }
        }
    }

    // MARK: - Display Mode

    @ViewBuilder
    private var displayView: some View {
        // Photo
        if let data = photoData, let ui = UIImage(data: data) {
            Section {
                HStack {
                    Spacer()
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .accessibilityLabel("\(brand) \(modelName) photo")
                    Spacer()
                }
            }
        }

        Section("Basic") {
            displayRow("Brand", value: brand)
            displayRow("Model", value: modelName)
            displayRow("Style", value: style.rawValue)
            displayRow("Movement", value: movement.rawValue)
        }

        Section("Size") {
            if let diameter = watch.caseDiameter {
                displayRow("Case Diameter", value: "\(String(format: "%.1f", diameter)) mm")
            }
            if let lug = watch.lugWidth {
                displayRow("Lug Width", value: "\(String(format: "%.1f", lug)) mm")
            }
            displayRow("Has Bracelet", value: hasBracelet ? "Yes" : "No")
        }

        Section("Service") {
            if let date = lastBatteryChange {
                displayRow("Last Battery Change", value: Self.dateFormatter.string(from: date))
            }
            if let date = lastServiced {
                displayRow("Last Serviced", value: Self.dateFormatter.string(from: date))
            }
            if lastBatteryChange == nil && lastServiced == nil {
                Text("No service history recorded")
                    .foregroundStyle(.secondary)
            }
        }

        Section("Status & Accuracy") {
            displayRow("Status", value: watchStatus.rawValue)
            if let acc = watch.accuracy {
                displayRow("Accuracy", value: "\(String(format: "%+.1f", acc)) s/day")
            }
            displayRow("Accuracy Method", value: accuracyMethod.rawValue)
            if let date = dateHacked {
                displayRow("Date Hacked", value: Self.dateFormatter.string(from: date))
            }
        }

        Section("Wear History") {
            if datesWorn.isEmpty {
                Text("Never worn")
                    .foregroundStyle(.secondary)
            } else {
                displayRow("Times Worn", value: "\(Set(datesWorn.map { Calendar.current.startOfDay(for: $0) }).count)")
                if let last = datesWorn.sorted().last {
                    displayRow("Last Worn", value: Self.dateFormatter.string(from: last))
                }
            }
        }

        Section("Special Occasions") {
            let sorted = watch.specialOccasions.sorted { $0.effectiveDate < $1.effectiveDate }
            if sorted.isEmpty {
                Text("No special occasions recorded")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(sorted) { occasion in
                    Button {
                        activeOccasionSheet = .edit(occasion)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(occasion.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            if occasion.recurrence == .none {
                                Text(occasion.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                if let next = occasion.nextOccurrence {
                                    Label("Next: \(next.formatted(date: .abbreviated, time: .omitted))", systemImage: "arrow.clockwise")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Text("Repeats \(occasion.recurrence.rawValue.lowercased())")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            if !occasion.notes.isEmpty {
                                Text(occasion.notes)
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 2)
                        .accessibilityElement(children: .combine)
                    }
                    .accessibilityHint("Tap to edit this occasion")
                }
            }
            Button("Add Special Occasion") {
                activeOccasionSheet = .add
            }
            .accessibilityHint("Opens the form to create a new special occasion for this watch")
        }

        Section {
            HStack {
                Text("Favorite")
                Spacer()
                Image(systemName: favorite ? "heart.fill" : "heart")
                    .foregroundStyle(favorite ? .red : .secondary)
                    .accessibilityHidden(true)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(favorite ? "Favorite: Yes" : "Favorite: No")
        }

        Section {
            Button("Delete Watch", role: .destructive) {
                showDeleteConfirmation = true
            }
            .accessibilityHint("Permanently removes this watch from your collection")
        }
    }

    private func displayRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
    }

    // MARK: - Edit Mode

    @ViewBuilder
    private var editView: some View {
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
                    Text(status.rawValue).tag(status)
                }
            }
            TextField("Accuracy (s/day)", text: $accuracyText)
                .keyboardType(.decimalPad)
            Picker("Accuracy method", selection: $accuracyMethod) {
                ForEach(AccuracyMethod.allCases, id: \.self) { method in
                    Text(method.rawValue).tag(method)
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
    }

    // MARK: - Actions

    private func resetFields() {
        brand = watch.brand
        modelName = watch.model
        style = watch.style
        movement = watch.movement
        caseDiameterText = watch.caseDiameter.map { String($0) } ?? ""
        lugWidthText = watch.lugWidth.map { String($0) } ?? ""
        hasBracelet = watch.hasBracelet
        lastBatteryChange = watch.lastBatteryChange
        lastServiced = watch.lastServiced
        watchStatus = watch.watchStatus
        accuracyText = watch.accuracy.map { String($0) } ?? ""
        accuracyMethod = watch.accuracyMethod
        dateHacked = watch.dateHacked
        datesWorn = watch.datesWorn
        photoData = watch.photo
        favorite = watch.favorite
    }

    private func saveChanges() {
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
        isEditing = false
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
