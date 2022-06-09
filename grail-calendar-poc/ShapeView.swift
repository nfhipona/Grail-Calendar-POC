//
//  ShapeView.swift
//  grail-calendar-poc
//
//  Created by Neil Francis Hipona on 6/8/22.
//

import SwiftUI

struct ShapeView: Shape {
  let path: Path

  init(path: Path) {
    self.path = path
  }

  init(with coordinates: [CGPoint], shouldClosePath: Bool = false) {
    var borderPath = Path()
    for (idx, coordinate) in coordinates.enumerated() {
        if idx > 0 {
            borderPath.addLine(to: coordinate)
        } else {
            borderPath.move(to: coordinate)
        }
    }

    if shouldClosePath {
        borderPath.closeSubpath()
    }

    self.path = borderPath
  }

  func path(in rect: CGRect) -> Path {
    return path
  }
}
