//
//  SpecialOccasionsView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 4/20/26.
//

import SwiftUI
import SwiftData
import TipKit

struct SpecialOccasionsView: View {

    private let recurringOccasionTip = RecurringOccasionTip()
    @Environment(\.modelContext) private var modelContext
    @Query private var occasions: [SpecialOccasion]

    @State private var activeSheet: OccasionListSheet?

    private enum OccasionListSheet: Identifiable {
        case add
        case edit(SpecialOccasion)
        var id: String {
            switch self {
            case .add: return "add"
            case .edit(let o): return o.persistentModelID.hashValue.description
            }
        }
    }

    /// Sorted ascending by effective date so upcoming occasions appear first.
    private var sorted: [SpecialOccasion] {
        occasions.sorted { $0.effectiveDate < $1.effectiveDate }
    }

    var body: some View {
        NavigationStack {
            List {
                if sorted.isEmpty {
                    ContentUnavailableView {
                        Label("No Special Occasions", systemImage: "star.circle")
                    } description: {
                        Text("Add occasions like \"Blue Watch Monday\" or \"St. Patrick's Day\" to track memorable wears.")
                    }
                } else {
                    ForEach(sorted) { occasion in
                        Button { activeSheet = .edit(occasion) } label: {
                            OccasionRow(occasion: occasion)
                        }
                        .accessibilityHint("Tap to edit this occasion")
                    }
                    .onDelete(perform: deleteOccasions)
                }
            }
            .navigationTitle("Special Occasions")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { activeSheet = .add } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Special Occasion")
                    .accessibilityHint("Opens the form to create a new special occasion")
                    .popoverTip(recurringOccasionTip)
                }
                if !sorted.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                }
            }
            .sheet(item: $activeSheet) { mode in
                switch mode {
                case .add:
                    AddEditSpecialOccasionView()
                case .edit(let occasion):
                    AddEditSpecialOccasionView(occasion: occasion)
                }
            }
        }
    }

    private func deleteOccasions(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sorted[index])
        }
        try? modelContext.save()
    }
}

private struct OccasionRow: View {
    let occasion: SpecialOccasion

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(occasion.name)
                .font(.headline)
                .foregroundStyle(.primary)

            if occasion.recurrence == .none {
                Text(occasion.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                if let next = occasion.nextOccurrence {
                    Label("Next: \(next.formatted(date: .abbreviated, time: .omitted))", systemImage: "arrow.clockwise")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text("Repeats \(occasion.recurrence.rawValue.lowercased())")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            if let watch = occasion.watch {
                Text("\(watch.brand) \(watch.model)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            if !occasion.notes.isEmpty {
                Text(occasion.notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let preview = PreviewContainer(Watch.self)
    preview.addSamples(Watch.sampleData)
    return SpecialOccasionsView()
        .modelContainer(preview.container)
}
