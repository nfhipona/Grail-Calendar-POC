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
    calendar.timeZone = .current
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
  @Published var month: MonthYearPickerViewModel.PickerData<String>
  @Published var year: MonthYearPickerViewModel.PickerData<Int>

  init(initialDate: Date = .now) {
    self.date = initialDate
    self.activeMonth = initialDate

    let month = calendar.component(.month, from: initialDate)
    let monthIdx = month - 1
    let monthName = Calendar.current.monthSymbols[monthIdx]
    let year = calendar.component(.year, from: initialDate)

    self.dates = CustomCalendarModel.collectDaysPerRow(calendar, forMonth: month, inYear: year)
    self.month = .init(idx: monthIdx, title: monthName, value: monthName)
    self.year = .init(idx: year, title: year.description, value: year)
  }
}

extension CustomCalendarModel {
  var currentMonthYear: String {
    // MMMMyyyy
    return "\(month.value) \(year.value)"
  }
}

extension CustomCalendarModel {
  class func dateRange(_ calendar: Calendar = .current, forMonth month: Int, inYear year: Int) -> ClosedRange<Int> {
    var start = DateComponents(calendar: calendar, timeZone: .current)
    start.day = 1
    start.month = month
    start.year = year

    var end = DateComponents(calendar: calendar, timeZone: .current)
    end.day = 1
    end.month = month + 1
    end.year = year

    return 1...calendar.dateComponents([.day], from: start, to: end).day!
  }

  func startOfDayInCurrentWeek(_ calendar: Calendar = .current, day: Int = 1, inMonth month: Int, inYear: Int) -> Weekday {
    var weekdaySubject = DateComponents(calendar: calendar, timeZone: .current)
    weekdaySubject.day = day
    weekdaySubject.month = month
    weekdaySubject.year = inYear

    let weekdayDate = calendar.date(from: weekdaySubject)!
    let weekday = calendar.component(.weekday, from: weekdayDate)
    return Weekday(rawValue: weekday)!
  }

  class func generateDays(_ calendar: Calendar = .current, forMonth month: Int, inYear: Int) -> [DayModel] {
    var dComponents = DateComponents(calendar: calendar, timeZone: .current)
    dComponents.day = 1
    dComponents.month = month
    dComponents.year = inYear

    let startDate = calendar.date(from: dComponents)!
    let range = dateRange(calendar, forMonth: month, inYear: inYear)
    let dayStartInWeek = Calendar.current.component(.weekday, from: startDate)

    var days: [DayModel] = []

    for _ in 1..<dayStartInWeek { // add offset
      days.append(DayModel(number: -1))
    }

    var dayComponents = DateComponents(calendar: calendar, timeZone: .current)
    dayComponents.calendar = calendar
    dayComponents.month = month
    dayComponents.year = inYear

    for i in range {
      dayComponents.day = i

      if let date = calendar.date(from: dayComponents) {
        let isSelected = calendar.isDateInToday(date)
        let model = DayModel(date: date, number: i, isSelected: isSelected)
        days.append(model)
      }
    }

    return days
  }

  class func isSameDay() {

  }

  class func collectDaysPerRow(_ calendar: Calendar = .current, forMonth month: Int, inYear: Int) -> [DayRowModel] {
    let days = generateDays(calendar, forMonth: month, inYear: inYear)

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

  func updateActiveMonth(monthIndex: Int) {
    let month = monthIndex + 1
    let year = year.value
    dates = CustomCalendarModel.collectDaysPerRow(calendar, forMonth: month, inYear: year)
  }

  func updateActiveYear(year: Int) {
    let month = month.idx + 1
    dates = CustomCalendarModel.collectDaysPerRow(calendar, forMonth: month, inYear: year)
  }
}
