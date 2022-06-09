//
//  CustomCalendarModel.swift
//  grail-calendar-poc
//
//  Created by Neil Francis Hipona on 6/9/22.
//

import Foundation
import SwiftUI

extension CustomCalendarModel {
  enum Weekday: Int, CaseIterable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday

    var description: String {
      switch self {
      case .sunday:
        return "Sunday"
      case .monday:
        return "Monday"
      case .tuesday:
        return "Tuesday"
      case .wednesday:
        return "Wednesday"
      case .thursday:
        return "Thursday"
      case .friday:
        return "Friday"
      case .saturday:
        return "Saturday"
      }
    }
  }
}

extension CustomCalendarModel {
  enum RowState {
    case `default`
    case rejected
    case warning

    var stateColor: Color {
      switch self {
      case .warning:
        return .orange
      case .rejected:
        return .red
      default:
        return .clear
      }
    }
  }

  struct DayModel {
    let id: UUID
    let date: Date?
    let number: Int
    let isSelected: Bool

    var isCurrentDate: Bool {
      if let date = date {
        let isCurrent = date == Date()
        return isCurrent
      }

      return false
    }

    init(id: UUID = UUID(), date: Date? = nil, number: Int, isSelected: Bool = false) {
      self.id = id
      self.date = date
      self.number = number
      self.isSelected = isSelected
    }

    func setSelected(isSelected: Bool) -> Self {
      .init(id: id, date: date, number: number, isSelected: isSelected)
    }
  }

  struct DayRowModel {
    let rows: [DayModel]
    let state: RowState

    var isRowActive: Bool {
      return !rows.filter { $0.isSelected }.isEmpty
    }
  }
}

class CustomCalendarModel: ObservableObject {
  private let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.locale = .current
    calendar.timeZone = TimeZone.current
    return calendar
  }()
  private let formatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.setLocalizedDateFormatFromTemplate("EEEEMMMMdyyyy")
    return dateFormatter
  }()

  @Published var date: Date
  @Published var activeMonth: Date

  @Published var dates: [DayRowModel] = []

  init(initialDate: Date = .now) {
    self.date = initialDate
    self.activeMonth = initialDate
    self.dates = collectDaysPerRow(forMonth: month(), inYear: year())
  }
}

extension CustomCalendarModel {
  var currentMonthYear: String {
    formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMMyyyy", options: 0, locale: .current)
    return formatter.string(from: date)
  }
}

extension CustomCalendarModel {
  func dateRange(forMonth month: Int, inYear year: Int) -> ClosedRange<Int> {
    var start = DateComponents()
    start.day = 1
    start.month = month
    start.year = year

    var end = DateComponents()
    end.day = 1
    end.month = month + 1
    end.year = year

    return 1...calendar.dateComponents([.day], from: start, to: end).day!
  }

  func month(withDate d: Date? = nil) -> Int {
    let from = d ?? date
    return calendar.component(.month, from: from)
  }

  func year(withDate d: Date? = nil) -> Int {
    let from = d ?? date
    return calendar.component(.year, from: from)
  }

  func startOfDayInCurrentWeek(day: Int = 1, inMonth month: Int, inYear: Int) -> Weekday {
    var weekdaySubject = DateComponents()
    weekdaySubject.day = day
    weekdaySubject.month = month
    weekdaySubject.year = inYear

    let weekdayDate = calendar.date(from: weekdaySubject)!
    let weekday = calendar.component(.weekday, from: weekdayDate)
    return Weekday(rawValue: weekday)!
  }

  func generateDays(forMonth month: Int, inYear: Int) -> [DayModel] {
    var dComponents = DateComponents()
    dComponents.day = 1
    dComponents.month = month
    dComponents.year = inYear

    let startDate = calendar.date(from: dComponents)!
    let range = dateRange(forMonth: month, inYear: inYear)

    let currentDay = calendar.component(.day, from: Date())
    let dayStartInWeek = Calendar.current.component(.weekday, from: startDate)

    var days: [DayModel] = []

    for _ in 1..<dayStartInWeek { // add offset
      days.append(DayModel(number: -1))
    }

    var dayComponents = DateComponents()
    dayComponents.month = month
    dayComponents.year = inYear

    for i in range {
      dayComponents.day = i

      if let date = calendar.date(from: dayComponents) {
        let model = DayModel(date: date, number: i, isSelected: i == currentDay)
        days.append(model)
      }
    }

    return days
  }

  func collectDaysPerRow(forMonth month: Int, inYear: Int) -> [DayRowModel] {
    let days = generateDays(forMonth: month, inYear: inYear)

    var daysCollection: [DayRowModel] = []
    var collectionIndex: Int = 0

    for _ in 1...6 {
      var daysRow: [DayModel] = []
      for _ in 1...7 {
        if collectionIndex < days.count {
          daysRow.append(days[collectionIndex])
          collectionIndex += 1
        }
      }

      if !daysRow.isEmpty {
        if daysRow.count < 7 {
          let fillCount = 7 - daysRow.count
          for _ in 1...fillCount { // add offset
            daysRow.append(DayModel(number: -1))
          }
        }

        daysCollection.append(DayRowModel(rows: daysRow, state: .default))
      }
    }

    return daysCollection
  }
}


extension CustomCalendarModel {
  func selectDate(with sd: DayModel) {
    print("selectDated: ", sd.number)

    var datesTmp: [DayRowModel] = []
    for d in dates {
      let rows = d.rows.map { d -> DayModel in
        let isSelected = d.id == sd.id
        return d.setSelected(isSelected: isSelected)
      }

      datesTmp.append(.init(rows: rows, state: .default))
    }
    dates = datesTmp
  }
}
