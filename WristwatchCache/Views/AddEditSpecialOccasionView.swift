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
    @State private var recurrence: OccasionRecurrence
    @State private var selectedWatch: Watch?

    init(occasion: SpecialOccasion? = nil, preselectedWatch: Watch? = nil) {
        self.occasion = occasion
        self.preselectedWatch = preselectedWatch
        _name       = State(initialValue: occasion?.name ?? "")
        _date       = State(initialValue: occasion?.date ?? Date())
        _notes      = State(initialValue: occasion?.notes ?? "")
        _recurrence = State(initialValue: occasion?.recurrence ?? .none)
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
                    DatePicker(
                        recurrence == .none ? "Date" : "Starting from",
                        selection: $date,
                        displayedComponents: .date
                    )
                }

                Section("Recurrence") {
                    Picker("Repeats", selection: $recurrence) {
                        ForEach(OccasionRecurrence.allCases, id: \.self) { rule in
                            Text(rule.rawValue).tag(rule)
                        }
                    }
                    if recurrence != .none {
                        recurrenceDescription
                    }
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

    @ViewBuilder
    private var recurrenceDescription: some View {
        let preview = SpecialOccasion(name: "", date: date, recurrence: recurrence)
        if let next = preview.nextOccurrence {
            HStack {
                Image(systemName: "arrow.clockwise")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                Text("Next: \(next.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        if let existing = occasion {
            existing.name       = trimmedName
            existing.date       = date
            existing.notes      = notes
            existing.recurrence = recurrence
            existing.watch      = selectedWatch
        } else {
            let newOccasion = SpecialOccasion(
                name: trimmedName,
                date: date,
                notes: notes,
                recurrence: recurrence,
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
