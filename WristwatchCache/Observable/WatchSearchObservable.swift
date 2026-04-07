//
//  WatchSearchObservable.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 4/7/26.
//

import Foundation
import Observation

@Observable
class WatchSearchObservable {
    var searchText: String = ""

    func filteredResults(from watches: [Watch]) -> [Watch] {
        if searchText.isEmpty {
            return watches
        } else {
            return watches.filter {
                $0.brand.localizedStandardContains(searchText) || $0.model.localizedStandardContains(searchText)
            }
        }
    }
}
