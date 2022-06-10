//
//  ContentView.swift
//  grail-calendar-poc
//
//  Created by Neil Francis Hipona on 6/8/22.
//

import SwiftUI

struct ContentView: View {
  @State private var date = Date()
  @State var location: CGPoint = .zero
  @State var month: MonthYearPickerViewModel.PickerData<String>? = nil
  @State var year: MonthYearPickerViewModel.PickerData<Int>? = nil

  var body: some View {
    GeometryReader { geometry in
      picker(geometry: geometry)
    }
  }

  private func picker(geometry: GeometryProxy) -> some View {
    MonthYearPickerView(model: .init(),
                        month: $month,
                        year: $year,
                        geometry: geometry)
    .onChange(of: month) { newValue in
      print("Month: ", newValue!)
    }
    .onChange(of: year) { newValue in
      print("Year: ", newValue!)
    }
  }

  private func pocCalendar(geometry: GeometryProxy) -> some View {
    VStack(spacing: 20) {
      VStack {
        Text("Apple")
          .font(.headline)
        DP1(date: $date)
      }

      VStack {
        Text("Custom")
          .font(.headline)
        CustomCalendar(model: .init(), geometry: geometry)
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
