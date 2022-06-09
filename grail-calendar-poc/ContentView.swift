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

  var body: some View {
    GeometryReader { geometry in
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
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
