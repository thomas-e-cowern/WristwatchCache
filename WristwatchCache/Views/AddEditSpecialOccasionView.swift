//
//  AddEditSpecialOccasionView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 4/20/26.
//

import SwiftUI
import SwiftData

struct AddEditSpecialOccasionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Watch.brand) private var watches: [Watch]

    var occasion: SpecialOccasion?
    private let preselectedWatch: Watch?

    @State private var name: String
    @State private var date: Date
    @State private var notes: String
    @State private var selectedWatch: Watch?

    init(occasion: SpecialOccasion? = nil, preselectedWatch: Watch? = nil) {
        self.occasion = occasion
        self.preselectedWatch = preselectedWatch
        _name = State(initialValue: occasion?.name ?? "")
        _date = State(initialValue: occasion?.date ?? Date())
        _notes = State(initialValue: occasion?.notes ?? "")
        _selectedWatch = State(initialValue: occasion?.watch ?? preselectedWatch)
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Occasion name", text: $name)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Watch") {
                    Picker("Watch", selection: $selectedWatch) {
                        Text("None").tag(Watch?.none)
                        ForEach(watches) { watch in
                            Text("\(watch.brand) \(watch.model)").tag(Watch?.some(watch))
                        }
                    }
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(occasion == nil ? "Add Occasion" : "Edit Occasion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") { save() }
                        .disabled(!isValid)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        if let existing = occasion {
            existing.name = trimmedName
            existing.date = date
            existing.notes = notes
            existing.watch = selectedWatch
        } else {
            let newOccasion = SpecialOccasion(
                name: trimmedName,
                date: date,
                notes: notes,
                watch: selectedWatch
            )
            modelContext.insert(newOccasion)
        }
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    let preview = PreviewContainer(Watch.self)
    preview.addSamples(Watch.sampleData)
    return AddEditSpecialOccasionView()
        .modelContainer(preview.container)
}
