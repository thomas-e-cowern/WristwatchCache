//
//  OnWristView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 4/1/26.
//

import SwiftUI
import SwiftData

struct OnWristView: View {

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Watch.brand) private var watches: [Watch]

    private var todaysWatch: Watch? {
        watches.first { watch in
            watch.datesWorn.contains { Calendar.current.isDateInToday($0) }
        }
    }

    private func selectWatch(_ watch: Watch) {
        watch.datesWorn.append(Date())
        try? modelContext.save()
    }

    var body: some View {
        NavigationStack {
            Group {
                if let watch = todaysWatch {
                    todaysWatchView(watch)
                } else {
                    selectionView
                }
            }
            .navigationTitle("On Your Wrist")
        }
    }

    // MARK: - Today's watch display

    private func todaysWatchView(_ watch: Watch) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                CardView(
                    imageData: watch.photo,
                    brand: watch.brand,
                    model: watch.model
                )
                .padding(.horizontal)

                VStack(spacing: 8) {
                    detailRow("Style", value: watch.style.rawValue)
                    detailRow("Movement", value: watch.movement.rawValue)
                    if let diameter = watch.caseDiameter {
                        detailRow("Case Size", value: "\(String(format: "%.0f", diameter))mm")
                    }
                    detailRow("Status", value: watch.watchStatus.rawValue)
                    detailRow("Times Worn", value: "\(watch.datesWorn.count)")
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

    // MARK: - Selection list

    private var selectionView: some View {
        List {
            Section {
                Text("No watch selected today. Tap one to put it on your wrist.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("Your Collection") {
                ForEach(watches) { watch in
                    Button {
                        selectWatch(watch)
                    } label: {
                        WatchRowView(watch: watch)
                    }
                    .tint(.primary)
                }
            }
        }
    }
}

#Preview {
    let preview = PreviewContainer(Watch.self)
    preview.addSamples(Watch.sampleData)
    return OnWristView()
        .modelContainer(preview.container)
}
