//
//  CardView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 4/1/26.
//

import SwiftUI

struct CardView: View {
    let imageData: Data?   // pass image bytes (e.g., from network or file)
    let brand: String
    let model: String
    var showWearButton: Bool = true
    
    private var uiImage: UIImage? {
        guard let data = imageData else { return nil }
        return UIImage(data: data)
    }
    
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            
            VStack {
                
                Spacer()
                
                // Prominent image
                Group {
                    if let img = uiImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                    } else {
                        // Placeholder
                        BrandView(brand: brand)
                    }
                }
                
                
                Spacer()
                
                // Text block
                VStack(alignment: .center, spacing: 4) {
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
            
            if showWearButton {
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
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

// Preview / example usage
struct CardView_Previews: PreviewProvider {
    static var sampleImageData: Data? {
        UIImage(systemName: "watch.analog")?
            .pngData()
    }
    
    static var previews: some View {
        CardView(
            imageData: sampleImageData,
            brand: "Dan Henry",
            model: "1946 Chronograph"
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

