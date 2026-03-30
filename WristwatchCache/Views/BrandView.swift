//
//  BrandView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 3/30/26.
//

import SwiftUI

import SwiftUI

struct BrandView: View {
    
    var brand: String // Assume this is passed in, e.g., "Apple" or "Samsung"

    var body: some View {
        VStack {
            Text(brand)
                .font(.title)
                .foregroundColor(.white) // Color of the text
                .padding(40) // Adds space between text and circle
                .background(brandColor(for: brand)) // Color of the circle
                .clipShape(Circle()) // Clips the background color to a circle shape
        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(brandColor(for: brand))
//        .ignoresSafeArea(.all) // Ensures the color fills the entire screen area
    }

    // Function to return the correct Color based on the brand
    func brandColor(for brand: String) -> Color {
        switch brand {
            // Major luxury & mainstream
            case "Rolex": return Color(red: 0.0/255, green: 96.0/255, blue: 57.0/255)    // #006039 (green)
            case "Rolex (Gold)": return Color(red: 163.0/255, green: 126.0/255, blue: 44.0/255) // #A37E2C (gold)
            case "Omega": return Color(red: 226.0/255, green: 28.0/255, blue: 42.0/255)    // #E21C2A (red)
            case "Seiko": return Color(red: 0.0/255, green: 51.0/255, blue: 153.0/255)     // #003399 (deep blue)
            case "Grand Seiko": return Color(red: 0.0/255, green: 82.0/255, blue: 165.0/255) // #0052A5 (GS blue)
            case "TAG Heuer": return Color(red: 0.0/255, green: 117.0/255, blue: 57.0/255)  // #007539 (green)
            case "TAG Heuer (Red)": return Color(red: 228.0/255, green: 0.0/255, blue: 43.0/255) // #E4002B (red)
            case "Patek Philippe": return Color(red: 27.0/255, green: 58.0/255, blue: 87.0/255) // #1B3A57 (navy)
            case "Audemars Piguet": return Color(red: 0.0/255, green: 58.0/255, blue: 99.0/255) // #003A63 (navy)
            case "IWC Schaffhausen": return Color(red: 30.0/255, green: 30.0/255, blue: 30.0/255) // #1E1E1E (charcoal)
            case "Jaeger‑LeCoultre": return Color(red: 27.0/255, green: 54.0/255, blue: 93.0/255) // #1B365D (dark blue)
            case "Panerai": return Color(red: 11.0/255, green: 59.0/255, blue: 46.0/255)     // #0B3B2E (deep green)
            case "Breitling": return Color(red: 255.0/255, green: 204.0/255, blue: 0.0/255)   // #FFCC00 (yellow)
            case "Tudor": return Color(red: 210.0/255, green: 35.0/255, blue: 42.0/255)      // #D2232A (red)
            case "Hublot": return Color(red: 0.0/255, green: 0.0/255, blue: 0.0/255)         // #000000 (black)
            case "Breguet": return Color(red: 29.0/255, green: 58.0/255, blue: 95.0/255)     // #1D3A5F (deep blue)
            case "Cartier": return Color(red: 198.0/255, green: 0.0/255, blue: 48.0/255)     // #C60030 (red)
            case "Vacheron Constantin": return Color(red: 10.0/255, green: 35.0/255, blue: 66.0/255) // #0A2342 (deep navy)
            case "Zenith": return Color(red: 0.0/255, green: 115.0/255, blue: 207.0/255)     // #0073CF (azure blue)
            case "Bulgari": return Color(red: 26.0/255, green: 26.0/255, blue: 26.0/255)     // #1A1A1A (black)
            case "Bulgari (Gold)": return Color(red: 200.0/255, green: 155.0/255, blue: 72.0/255) // #C89B48 (gold)
            case "Longines": return Color(red: 0.0/255, green: 51.0/255, blue: 153.0/255)    // #003399 (blue)
            case "Rado": return Color(red: 0.0/255, green: 0.0/255, blue: 0.0/255)          // #000000 (black)
            
            // Affordable / common
            case "Timex": return Color(red: 0.0/255, green: 51.0/255, blue: 102.0/255)      // #003366 (navy)
            case "Citizen": return Color(red: 0.0/255, green: 94.0/255, blue: 184.0/255)    // #005EB8 (blue)
            case "Casio": return Color(red: 0.0/255, green: 0.0/255, blue: 0.0/255)         // #000000 (black)
            case "Casio (G-Shock Accent)": return Color(red: 255.0/255, green: 0.0/255, blue: 0.0/255) // #FF0000 (red)
            case "Orient": return Color(red: 30.0/255, green: 58.0/255, blue: 95.0/255)      // #1E3A5F (dark blue)
            case "Fossil": return Color(red: 31.0/255, green: 31.0/255, blue: 31.0/255)     // #1F1F1F (charcoal)
            case "Bulova": return Color(red: 11.0/255, green: 72.0/255, blue: 107.0/255)    // #0B486B (deep teal/blue)
            case "Swatch": return Color(red: 255.0/255, green: 75.0/255, blue: 0.0/255)      // #FF4B00 (orange)
            case "Hamilton": return Color(red: 10.0/255, green: 46.0/255, blue: 98.0/255)    // #0A2E62 (navy)
            case "Skagen": return Color(red: 43.0/255, green: 43.0/255, blue: 43.0/255)      // #2B2B2B (dark gray)
            case "MVMT": return Color(red: 0.0/255, green: 0.0/255, blue: 0.0/255)          // #000000 (black)
            case "Invicta": return Color(red: 249.0/255, green: 166.0/255, blue: 2.0/255)   // #F9A602 (gold/yellow)
            case "Polar": return Color(red: 0.0/255, green: 174.0/255, blue: 239.0/255)     // #00AEEF (cyan)
            case "Garmin": return Color(red: 0.0/255, green: 112.0/255, blue: 184.0/255)    // #0070B8 (blue)
            case "Suunto": return Color(red: 0.0/255, green: 122.0/255, blue: 135.0/255)    // #007A87 (teal)
            case "Nixon": return Color(red: 28.0/255, green: 28.0/255, blue: 28.0/255)      // #1C1C1C (black)
            case "Michael Kors": return Color(red: 198.0/255, green: 168.0/255, blue: 106.0/255) // #C6A86A (rose/gold)
            case "Sekonda": return Color(red: 13.0/255, green: 59.0/255, blue: 102.0/255)   // #0D3B66 (deep blue)

            // Microbrands
            case "Dan Henry": return Color(red: 27.0/255, green: 27.0/255, blue: 27.0/255)   // #1B1B1B (black)
            case "Dan Henry (Gilt)": return Color(red: 197.0/255, green: 157.0/255, blue: 95.0/255) // #C59D5F (gilt)
            case "Vaer": return Color(red: 11.0/255, green: 110.0/255, blue: 138.0/255)      // #0B6E8A (teal)
            case "Lorier": return Color(red: 15.0/255, green: 76.0/255, blue: 129.0/255)     // #0F4C81 (navy)
            case "Halios": return Color(red: 10.0/255, green: 35.0/255, blue: 66.0/255)      // #0A2342 (deep navy)
            case "Baltic": return Color(red: 10.0/255, green: 59.0/255, blue: 92.0/255)      // #0A3B5C (midnight blue)
            case "Zelos": return Color(red: 0.0/255, green: 47.0/255, blue: 77.0/255)        // #002F4D (deep teal)
            case "Zelos (Gold)": return Color(red: 212.0/255, green: 175.0/255, blue: 55.0/255) // #D4AF37 (gold)
            case "Farer": return Color(red: 255.0/255, green: 107.0/255, blue: 53.0/255)     // #FF6B35 (orange)
            case "Farer (Blue)": return Color(red: 11.0/255, green: 61.0/255, blue: 145.0/255) // #0B3D91 (blue)
            case "Nodus": return Color(red: 14.0/255, green: 43.0/255, blue: 79.0/255)       // #0E2B4F (navy)
            case "Monta": return Color(red: 17.0/255, green: 17.0/255, blue: 17.0/255)      // #111111 (black)
            case "Monta (Gold)": return Color(red: 191.0/255, green: 161.0/255, blue: 96.0/255) // #BFA160 (gold)
            case "Unimatic": return Color(red: 0.0/255, green: 0.0/255, blue: 0.0/255)      // #000000 (black)
            case "Unimatic (White)": return Color(red: 255.0/255, green: 255.0/255, blue: 255.0/255) // #FFFFFF
            case "Autodromo": return Color(red: 30.0/255, green: 30.0/255, blue: 30.0/255)   // #1E1E1E (charcoal)
            case "Autodromo (Red Accent)": return Color(red: 184.0/255, green: 39.0/255, blue: 44.0/255) // #B8272C
            case "Ming": return Color(red: 14.0/255, green: 34.0/255, blue: 63.0/255)        // #0E223F (indigo)
            case "Halda": return Color(red: 0.0/255, green: 58.0/255, blue: 99.0/255)        // #003A63 (navy)
            case "Oak & Oscar": return Color(red: 11.0/255, green: 59.0/255, blue: 111.0/255) // #0B3B6F (navy)
            case "Oak & Oscar (Gold)": return Color(red: 196.0/255, green: 154.0/255, blue: 108.0/255) // #C49A6C
            case "Nethuns": return Color(red: 0.0/255, green: 78.0/255, blue: 100.0/255)     // #004E64 (aqua)
            case "Vario": return Color(red: 17.0/255, green: 17.0/255, blue: 17.0/255)       // #111111 (black)
            case "Vario (Amber)": return Color(red: 255.0/255, green: 180.0/255, blue: 0.0/255) // #FFB400
            case "Vertex": return Color(red: 29.0/255, green: 58.0/255, blue: 95.0/255)      // #1D3A5F (navy)
        default:
            return Color.black
        }
    }
}


#Preview {
    BrandView(brand: "Vaer")
}
