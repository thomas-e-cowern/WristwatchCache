//
//  CardView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 4/1/26.
//

import SwiftUI

struct CardView: View {
    let image: Image      // pass in an Image (e.g., Image("photo") or Image(uiImage:...))
    let brand: String     // first line of text
    let model: String  // second line of text

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            
            HStack {
                
                Spacer()
                
                // Prominent image
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .clipped()
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4)

                
                Spacer()
                
                // Text block
                VStack(alignment: .leading, spacing: 4) {
                    Text(brand)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(model)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            
            Button(action: {
                // More to come
            }) {
                Text("Wear Today")
                    .font(.subheadline.bold())
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

// Preview / example usage
struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(
            image: Image(systemName: "watch.analog"),
            brand: "Omega",
            model: "Speedmaster"
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

