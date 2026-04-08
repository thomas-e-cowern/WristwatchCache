//
//  BrandStatsView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 4/7/26.
//

import SwiftUI

struct BrandStatsView: View {
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
                    .foregroundColor(idealTextColor(for: color))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text("\(number)")
                    .font(.title)
                    .bold()
                    .foregroundColor(idealTextColor(for: color))
            }
            .padding(12)
        }
        .frame(width: 196, height: 196)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label), \(number)")
    }

    // Choose black or white text depending on background luminance for contrast
    private func idealTextColor(for background: Color) -> Color {
        #if canImport(UIKit)
        // Convert SwiftUI Color to UIColor
        let uiColor = UIColor(background)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #else
        let nsColor = NSColor(background)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #endif

        // Perceived luminance
        let luminance = 0.299 * Double(red) + 0.587 * Double(green) + 0.114 * Double(blue)
        return luminance > 0.6 ? .black : .white
    }
}


#Preview {
    BrandStatsView(label: "Timex", color: BrandView.brandColor(for: "Timex"), number: 7)
}
