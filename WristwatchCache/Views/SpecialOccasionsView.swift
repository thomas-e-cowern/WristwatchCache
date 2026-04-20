//
//  SpecialOccasionsView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 4/20/26.
//

import SwiftUI
import SwiftData

struct SpecialOccasionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SpecialOccasion.date, order: .reverse) private var occasions: [SpecialOccasion]

    @State private var showAddSheet = false
    @State private var occasionToEdit: SpecialOccasion?

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    var body: some View {
        NavigationStack {
            List {
                if occasions.isEmpty {
                    ContentUnavailableView {
                        Label("No Special Occasions", systemImage: "star.circle")
                    } description: {
                        Text("Add occasions like \"Blue Watch Monday\" or \"St. Patrick's Day\" to track memorable wears.")
                    }
                } else {
                    ForEach(occasions) { occasion in
                        Button {
                            occasionToEdit = occasion
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(occasion.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(Self.dateFormatter.string(from: occasion.date))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
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
                        }
                    }
                    .onDelete(perform: deleteOccasions)
                }
            }
            .navigationTitle("Special Occasions")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                if !occasions.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddEditSpecialOccasionView()
            }
            .sheet(item: $occasionToEdit) { occasion in
                AddEditSpecialOccasionView(occasion: occasion)
            }
        }
    }

    private func deleteOccasions(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(occasions[index])
        }
        try? modelContext.save()
    }
}

#Preview {
    let preview = PreviewContainer(Watch.self)
    preview.addSamples(Watch.sampleData)
    return SpecialOccasionsView()
        .modelContainer(preview.container)
}
