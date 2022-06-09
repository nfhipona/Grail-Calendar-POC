//
//  DP1.swift
//  grail-calendar-poc
//
//  Created by Neil Francis Hipona on 6/9/22.
//

import SwiftUI

struct DP1: View {
  @Binding var date: Date
  @State var location: CGPoint = .zero

  init(date: Binding<Date>) {
    _date = date
  }

  var body: some View {
    GeometryReader { geometry in
      VStack {
        /*
        DatePicker(
          "wheel Date",
          selection: $date,
          displayedComponents: [.date]
        )
        .datePickerStyle(.wheel)

        DatePicker(
          "compact Date",
          selection: $date,
          displayedComponents: [.date]
        )
        .datePickerStyle(.compact)
        */

        DatePicker(
          "graphical Date",
          selection: $date,
          displayedComponents: [.date]
        )
        .datePickerStyle(.graphical)
//        .background {
//          GeometryReader { geometry in
//            let center = location.y
//            let halfSize: CGFloat = 25
//            let p1 = CGPoint(x: 0, y: center - halfSize)
//            let p2 = CGPoint(x: geometry.size.width, y: center - halfSize)
//            let p3 = CGPoint(x: geometry.size.width, y: center + halfSize)
//            let p4 = CGPoint(x: 0, y: center + halfSize)
//            ShapeView(with: [p1, p2, p3, p4], shouldClosePath: true)
//              .stroke(.orange, lineWidth: 1)
//              .onAppear {
//                print("size:", geometry.size)
//                print("center:", center)
//              }
//          }
//        }
//        .onTapWithLocation { loc in
//          print("a:", loc)
//          location = loc
//        }

      }
    }
  }
}

struct DP1_Previews: PreviewProvider {
  @State static var date: Date = .now
    static var previews: some View {
      DP1(date: $date)
    }
}
