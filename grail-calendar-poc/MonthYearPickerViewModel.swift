//
//  MonthYearPickerViewModel.swift
//  grail-calendar-poc
//
//  Created by Neil Francis Hipona on 6/10/22.
//

import Foundation

extension MonthYearPickerViewModel {
  struct PickerData<T: Hashable>: Identifiable, Hashable {
    let id: UUID
    let idx: Int
    let title: String
    let value: T

    init(idx: Int, title: String, value: T) {
      self.id = UUID()
      self.idx = idx
      self.title = title
      self.value = value
    }

    static func == (lhs: MonthYearPickerViewModel.PickerData<T>, rhs: MonthYearPickerViewModel.PickerData<T>) -> Bool {
      return lhs.id == rhs.id && lhs.idx == rhs.idx && lhs.title == rhs.title && lhs.value == rhs.value
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
      hasher.combine(idx)
      hasher.combine(title)
      hasher.combine(value)
    }
  }
}

class MonthYearPickerViewModel: ObservableObject {
  private let minYear: Int // offset limit from the current year
  private let maxYear: Int // offset limit from the current year

  let monthsData: [PickerData<String>]
  let yearsData: [PickerData<Int>]

  init(minYear: Int = 5, maxYear: Int = 10) {
    self.minYear = minYear
    self.maxYear = maxYear

    self.monthsData = MonthYearPickerViewModel.generateMonths()
    self.yearsData = MonthYearPickerViewModel.generateYears(minYear: minYear, maxYear: maxYear)
  }
}

extension MonthYearPickerViewModel {
  class  func generateMonths() -> [PickerData<String>] {
    var data: [PickerData<String>] = []
    for (idx, month) in Calendar.current.monthSymbols.enumerated() {
      data.append(PickerData(idx: idx, title: month, value: month))
    }
    return data
  }

  class func generateYears(minYear: Int = 5, maxYear: Int = 10) -> [PickerData<Int>] {
    var data: [PickerData<Int>] = []
    let currentYear = Calendar.current.dateComponents([.year], from: Date()).year!

    let minYearLimit = currentYear - minYear
    for i in minYearLimit..<currentYear {
      data.append(PickerData(idx: i, title: i.description, value: i))
    }

    let maxYearLimit = currentYear + maxYear
    for i in currentYear...maxYearLimit {
      data.append(PickerData(idx: i, title: i.description, value: i))
    }

    return data
  }
}
