//
//  PhotoPickerSection.swift
//  WristwatchCache
//

import SwiftUI
import PhotosUI

struct PhotoPickerSection: View {
    @Binding var photoData: Data?

    @State private var photosPickerItems: [PhotosPickerItem] = []
    @State private var showCamera = false

    var body: some View {
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
                Button("Remove Photo", role: .destructive) {
                    photoData = nil
                }
            }
        }
    }
}
