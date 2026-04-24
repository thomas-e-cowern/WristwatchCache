//
//  DetailRowView.swift
//  WristwatchCache
//

import SwiftUI

struct DetailRowView: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    DetailRowView(label: "Style", value: "Dress")
}
