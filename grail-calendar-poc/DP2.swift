//
//  DP2.swift
//  grail-calendar-poc
//
//  Created by Neil Francis Hipona on 6/9/22.
//

import SwiftUI
import UIKit

struct DP2: UIViewRepresentable {
  typealias UIViewType = UIDatePicker

  @Binding var date: Date

  init(date: Binding<Date>) {
    _date = date
  }

  func makeUIView(context: Context) -> UIDatePicker {
    let picker = UIDatePicker(frame: .zero, primaryAction: UIAction(title: "Test",
                                                                    image: UIImage(systemName: "play"),
                                                                    identifier: .pasteAndGo, discoverabilityTitle: "Test", attributes: .destructive,
                                                                    state: .mixed,
                                                                    handler: { action in
      print("action:", action)
      print("action.attributes:", action.attributes)
      
    }))
    picker.preferredDatePickerStyle = .inline
    picker.datePickerMode = .date

    return picker
  }

  func updateUIView(_ uiView: UIDatePicker, context: Context) {
    for (idx, view) in uiView.subviews.enumerated() {
      print("v \(idx):", view)

      for (idx, view) in view.subviews.enumerated() {
        print("v2 \(idx):", view)

        for (idx, view) in view.subviews.enumerated() {
          print("v3 \(idx):", type(of: view))

          if String(describing: type(of: view)) == "_UIDatePickerCalendarDateView" {

            for (idx, view) in view.subviews.enumerated() {
              print("v4 \(idx):", view)

              if view.isKind(of: UICollectionView.self) {

                for (idx, view) in view.subviews.enumerated() {
                  print("v5 \(idx):", view)
                }
              }
            }
          }
        }
      }
    }
  }
}

struct DP2_Previews: PreviewProvider {
  @State static var date: Date = .now
    static var previews: some View {
      DP2(date: $date)
    }
}
