//
//  MonthYearPickerView.swift
//  grail-calendar-poc
//
//  Created by Neil Francis Hipona on 6/10/22.
//

import SwiftUI

struct MonthYearPickerView: View {
  @StateObject private var model: MonthYearPickerViewModel
  @Binding private var month: MonthYearPickerViewModel.PickerData<String>?
  @Binding private var year: MonthYearPickerViewModel.PickerData<Int>?
  private let geometry: GeometryProxy

  @State private var monthSelection: Int = 0
  @State private var yearSelection: Int = 0

  init(model: MonthYearPickerViewModel,
       month: Binding<MonthYearPickerViewModel.PickerData<String>?>,
       year: Binding<MonthYearPickerViewModel.PickerData<Int>?>,
       geometry: GeometryProxy) {

    _model = .init(wrappedValue: model)
    _month = month
    _year = year
    
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
          month = selectedData
        }
      }
      .onChange(of: yearSelection) { newValue in
        let filteredData = model.yearsData.filter { $0.idx == newValue }
        if let selectedData = filteredData.first {
          year = selectedData
        }
      }
    }
    .frame(width: geometry.size.width, alignment: .center)
  }
}

struct MonthYearPicker_Previews: PreviewProvider {
  @State static var month: MonthYearPickerViewModel.PickerData<String>? = nil
  @State static var year: MonthYearPickerViewModel.PickerData<Int>? = nil

  static var previews: some View {
    GeometryReader { geometry in
      MonthYearPickerView(model: .init(),
                          month: $month,
                          year: $year,
                          geometry: geometry)
    }
  }
}
