//
//  OptionalDatePickerRow.swift
//  WristwatchCache
//

import SwiftUI

struct OptionalDatePickerRow: View {
    let toggleLabel: String
    let pickerLabel: String
    @Binding var date: Date?

    @State private var isEnabled: Bool

    init(toggleLabel: String, pickerLabel: String, date: Binding<Date?>) {
        self.toggleLabel = toggleLabel
        self.pickerLabel = pickerLabel
        self._date = date
        self._isEnabled = State(initialValue: date.wrappedValue != nil)
    }

    var body: some View {
        Toggle(toggleLabel, isOn: Binding(
            get: { date != nil },
            set: { newValue in
                isEnabled = newValue
                if newValue && date == nil { date = Date() }
                if !newValue { date = nil }
            }
        ).animation())

        if isEnabled || date != nil {
            DatePicker(pickerLabel, selection: Binding(
                get: { date ?? Date() },
                set: { date = $0 }
            ), displayedComponents: .date)
        }
    }
}
