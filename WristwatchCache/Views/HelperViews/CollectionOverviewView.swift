//
//  CollectionOverviewView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 4/17/26.
//

import SwiftUI
import SwiftData

struct CollectionOverviewView: View {
    
    @Query(sort: \Watch.brand) private var watches: [Watch]
    
    private var stats: WatchStatistics {
        WatchStatistics(watches: watches)
    }
    
    var body: some View {
        NavigationLink {
            WatchListView()
        } label: {
            LabeledContent("Total Watches", value: "\(watches.count)")
        }

        
        LabeledContent("Total Wears Logged", value: "\(stats.totalWears)")
        
        NavigationLink {
            UnwornWatchView()
        } label: {
            LabeledContent("Never Worn", value: "\(stats.neverWorn.count)")
        }

        
    }
}

#Preview {
    CollectionOverviewView()
}
