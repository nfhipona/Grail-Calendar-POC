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

  @State var monthYear: MonthYearPickerViewModel.MonthYearData = .init(month: 04, year: 2022)
  var body: some View {
    GeometryReader { geometry in
      pocCalendar(geometry: geometry)
    }
  }

  private func picker(geometry: GeometryProxy) -> some View {
    MonthYearPickerView(model: .init(),
                        monthYear: $monthYear,
                        geometry: geometry)
    .onChange(of: monthYear) { newValue in
      print("Month: ", newValue)
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
