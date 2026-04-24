//
//  CircularStatsView.swift
//  WristwatchCache
//

import SwiftUI

struct CircularStatsView: View {
    let label: String
    let color: Color
    let number: Int

    var body: some View {
        ZStack {
            Circle()
                .fill(color)
            VStack(spacing: 4) {
                Text(label)
                    .font(.title2)
                    .foregroundColor(color.idealTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text("\(number)")
                    .font(.title)
                    .bold()
                    .foregroundColor(color.idealTextColor)
            }
            .padding(12)
        }
        .frame(width: 196, height: 196)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label), \(number)")
    }
}

typealias BrandStatsView = CircularStatsView
typealias StyleStatsView = CircularStatsView
typealias MovementStatsView = CircularStatsView

#Preview {
    CircularStatsView(label: "Timex", color: Color.brown, number: 7)
}
