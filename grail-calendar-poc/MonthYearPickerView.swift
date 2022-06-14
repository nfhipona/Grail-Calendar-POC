//
//  MonthYearPickerView.swift
//  grail-calendar-poc
//
//  Created by Neil Francis Hipona on 6/10/22.
//

import SwiftUI

struct MonthYearPickerView: View {
  @StateObject private var model: MonthYearPickerViewModel
  @Binding private var monthYear: MonthYearPickerViewModel.MonthYearData
  private let geometry: GeometryProxy

  @State private var monthSelection: Int
  @State private var yearSelection: Int

  init(model: MonthYearPickerViewModel,
       monthYear: Binding<MonthYearPickerViewModel.MonthYearData>,
       geometry: GeometryProxy) {

    _model = .init(wrappedValue: model)
    _monthYear = monthYear

    _monthSelection = .init(initialValue: monthYear.wrappedValue.month)
    _yearSelection = .init(initialValue: monthYear.wrappedValue.year)

    self.geometry = geometry
  }

  var body: some View {
    HStack(spacing: 0) {
      let contentWidth = geometry.size.width / 2

      Picker("Month", selection: $monthSelection) {
        ForEach(model.monthsData, id: \.idx) { data in
          Text(data.title)
            .accessibilityLabel(data.title)
        }
      }
      .frame(width: contentWidth, alignment: .center)
      .pickerStyle(.wheel)

      Spacer(minLength: 0)
      Picker("Year", selection: $yearSelection) {
        ForEach(model.yearsData, id: \.idx) { data in
          Text(data.title)
            .accessibilityLabel(data.title)
        }
      }
      .frame(width: contentWidth, alignment: .center)
      .pickerStyle(.wheel)
      .onChange(of: monthSelection) { newValue in
        let filteredData = model.monthsData.filter { $0.idx == newValue }
        if let selectedData = filteredData.first {
          monthYear = .init(month: selectedData.value, year: monthYear.year)
        }
      }
      .onChange(of: yearSelection) { newValue in
        let filteredData = model.yearsData.filter { $0.idx == newValue }
        if let selectedData = filteredData.first {
          monthYear = .init(month: monthYear.month, year: selectedData.value)
        }
      }
    }
    .frame(width: geometry.size.width, alignment: .center)
  }
}

struct MonthYearPicker_Previews: PreviewProvider {
  @State static var monthYear: MonthYearPickerViewModel.MonthYearData = .init(month: 04, year: 2022)
  static var previews: some View {
    GeometryReader { geometry in
      MonthYearPickerView(model: .init(),
                          monthYear: $monthYear,
                          geometry: geometry)
    }
  }
}
