//
//  Modifier.swift
//  grail-calendar-poc
//
//  Created by Neil Francis Hipona on 6/8/22.
//

import Foundation
import SwiftUI
import UIKit

// https://stackoverflow.com/questions/56513942/how-to-detect-a-tap-gesture-location-in-swiftui

public extension View {
  func onTapWithLocation(coordinateSpace: CoordinateSpace = .local, _ tapHandler: @escaping (CGPoint) -> Void) -> some View {
    modifier(TapLocationViewModifier(tapHandler: tapHandler, coordinateSpace: coordinateSpace))
  }
}

fileprivate struct TapLocationViewModifier: ViewModifier {
  let tapHandler: (CGPoint) -> Void
  let coordinateSpace: CoordinateSpace

  func body(content: Content) -> some View {
    content.overlay {
      TapLocationBackground(tapHandler: tapHandler, coordinateSpace: coordinateSpace)
    }
  }
}

fileprivate struct TapLocationBackground: UIViewRepresentable {
  var tapHandler: (CGPoint) -> Void
  let coordinateSpace: CoordinateSpace

  func makeUIView(context: UIViewRepresentableContext<TapLocationBackground>) -> UIView {
    let v = UIView(frame: .zero)
    let gesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped))
    v.addGestureRecognizer(gesture)
    return v
  }

  class Coordinator: NSObject {
    var tapHandler: (CGPoint) -> Void
    let coordinateSpace: CoordinateSpace

    init(handler: @escaping ((CGPoint) -> Void), coordinateSpace: CoordinateSpace) {
      self.tapHandler = handler
      self.coordinateSpace = coordinateSpace
    }

    @objc func tapped(gesture: UITapGestureRecognizer) {
      let point = coordinateSpace == .local
      ? gesture.location(in: gesture.view)
      : gesture.location(in: nil)
      tapHandler(point)
    }
  }

  func makeCoordinator() -> TapLocationBackground.Coordinator {
    Coordinator(handler: tapHandler, coordinateSpace: coordinateSpace)
  }

  func updateUIView(_ view: UIView, context _: UIViewRepresentableContext<TapLocationBackground>) {
    /* nothing */
    print("v:", view)
  }
}
