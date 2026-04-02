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
    @State private var isChanging = false
    @State private var showAddWatch = false

    private var todaysWatch: Watch? {
        watches.first { watch in
            watch.datesWorn.contains { Calendar.current.isDateInToday($0) }
        }
    }

    private func selectWatch(_ watch: Watch) {
        watch.datesWorn.append(Date())
        try? modelContext.save()
        isChanging = false
    }

    var body: some View {
        NavigationStack {
            Group {
                if let watch = todaysWatch, !isChanging {
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
                    detailRow("Status", value: watch.watchStatus.rawValue)
                    detailRow("Times Worn", value: "\(watch.datesWorn.count)")
                }
                .padding(.horizontal)

                Button {
                    isChanging = true
                } label: {
                    Label("Change Watch", systemImage: "arrow.triangle.2.circlepath")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
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
                Text(isChanging
                     ? "Pick a different watch to wear today."
                     : "No watch selected today. Tap one to put it on your wrist.")
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
        .sheet(isPresented: $showAddWatch) {
            AddWatchView()
        }
        .overlay {
            VStack {
                if watches.isEmpty {
                    ContentUnavailableView {
                        Label("No watches in your collection", systemImage: "watch.analog")
                    } description: {
                        Text("You haven't addad any watches yet.  Please click below to add one")
                    } actions: {
                        AddWatchButton()
                            .buttonStyle(.borderedProminent)
                    }
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
