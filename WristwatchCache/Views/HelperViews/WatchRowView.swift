//
//  WatchRowView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 4/1/26.
//

import SwiftUI

struct WatchRowView: View {
    
    let watch: Watch
    
    var body: some View {
        HStack(spacing: 24) {
            BrandView(brand: watch.brand)
                .accessibilityHidden(true)
            VStack(alignment: .leading) {
                Text(watch.brand)
                    .font(.headline)
                Text(watch.model)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    WatchRowView(watch: Watch.sampleData[2])
}
