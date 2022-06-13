//
//  CustomCalendar.swift
//  grail-calendar-poc
//
//  Created by Neil Francis Hipona on 6/9/22.
//

import SwiftUI

struct CustomCalendar: View {
  @StateObject private var model: CustomCalendarModel
  private var geometry: GeometryProxy
  private let padding: CGFloat

  @State private var showMonthYearPicker: Bool = false

  init(model: CustomCalendarModel, geometry: GeometryProxy, padding: CGFloat = 14) {
    _model = .init(wrappedValue: model)
    self.geometry = geometry
    self.padding = padding
  }

  var body: some View {
    VStack(spacing: 0) {
      let contentWidth = abs(geometry.size.width - (padding * 2))
      HStack {
        monthButton()
        Spacer()
        monthNavigationButton()
      }
      .frame(width: contentWidth, height: 50, alignment: .center)

      VStack {
        drawDaysOfTheMonthTitleViewStack(contentWidth: contentWidth)
        drawDaysOfTheMonthViewStack(contentWidth: contentWidth)
      }
      .overlay {
        if showMonthYearPicker {
          GeometryReader { geometry in
            buildMonthPickerViewStack(geometry: geometry)
              .transition(.move(edge: .top))
          }
        }
      }
    }
    .padding(.horizontal, 20)
    .frame(width: geometry.size.width, alignment: .center)
  }

  private func monthButton() -> some View {
    Button {
      withAnimation {
        showMonthYearPicker = !showMonthYearPicker
      }
    } label: {
      HStack {
        let font = Font.system(size: 18, weight: .bold, design: .rounded)
        Text(model.currentMonthYear)
          .accessibilityLabel(model.currentMonthYear)
          .foregroundColor(.black)
          .font(font)
        Image(systemName: "chevron.right")
          .font(font)
          .foregroundColor(.blue)
      }
      .frame(height: 40, alignment: .leading)
    }
  }

  private func monthNavigationButton() -> some View {
    HStack {
      let font = Font.system(size: 18, weight: .bold, design: .rounded)
      Image(systemName: "chevron.left")
        .font(font)

      Image(systemName: "chevron.right")
        .font(font)
    }
    .frame(height: 40, alignment: .leading)
    .foregroundColor(.blue)
  }

  private func drawDaysOfTheMonthTitleViewStack(contentWidth: CGFloat) -> some View {
    HStack(spacing: 0) {
      let dayWidth = contentWidth / CGFloat(Calendar.current.shortWeekdaySymbols.count)
      ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { weekDay in
        Text(weekDay.uppercased())
          .foregroundColor(.black.opacity(0.5))
          .frame(width: dayWidth, alignment: .center)
      }
    }
    .frame(width: contentWidth, height: 30, alignment: .center)
  }

  @ViewBuilder
  private func drawDaysOfTheMonthViewStack(contentWidth: CGFloat) -> some View {
    let dayWidth = contentWidth / CGFloat(Calendar.current.shortWeekdaySymbols.count)
    let daysContainerHeight = dayWidth * 6 + 40
    VStack(spacing: 10) {
      let range = 0..<model.dates.count
      ForEach(range, id: \.self) { i in
        let collection = model.dates[i]
        drawDaysOfTheMonthRowViewStack(contentWidth: contentWidth, rowModel: collection)
      }
    }
    .frame(width: contentWidth, height: daysContainerHeight, alignment: .top)
  }

  @ViewBuilder
  private func drawDaysOfTheMonthRowViewStack(contentWidth: CGFloat, rowModel: CustomCalendarModel.DayRowModel) -> some View {
    let dayWidth = contentWidth / CGFloat(Calendar.current.shortWeekdaySymbols.count)
    HStack(spacing: 0) {
      ForEach(rowModel.rows, id: \.id) { day in
        if let _ = day.date {
          let font = day.isSelected ? Font.system(size: 20, weight: .bold, design: .default) : Font.system(size: 20, weight: .regular, design: .default)
          Button {
            model.selectDate(with: day)
          } label: {
            Text(day.number.description)
              .font(font)
              .foregroundColor(.black)
              .frame(width: dayWidth, height: dayWidth, alignment: .center)
          }
          .background(day.isSelected ? .blue : .clear)
          .mask {
            GeometryReader { geometry in
              if day.isSelected {
                let width = geometry.size.width - 20
                let height = geometry.size.height - 20
                let path = Path(roundedRect: .init(x: 10, y: 10, width: width, height: height), cornerRadius: width / 2)
                ShapeView(path: path)
              } else {
                let rect = CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height)
                ShapeView(path: .init(rect))
              }
            }
          }
        } else {
          VStack { }
            .frame(width: dayWidth, height: dayWidth, alignment: .center)
        }
      }
    }
    .frame(width: contentWidth, height: dayWidth, alignment: .leading)
    .background {
      GeometryReader { geometry in
        VStack{
          RoundedRectangle(cornerRadius: geometry.size.height / 2)
            .frame(width: geometry.size.width, height: 48, alignment: .center)
            .foregroundColor(rowModel.isRowActive ? .green : rowModel.state.stateColor)
        }
        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
      }
    }
  }

  private func buildMonthPickerViewStack(geometry: GeometryProxy) -> some View {
    MonthYearPickerView(model: .init(),
                        month: $model.month,
                        year: $model.year,
                        geometry: geometry)
    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
    .background(.white)
    .onChange(of: model.month) { newValue in
      print("Month: ", newValue)
      model.updateActiveMonth(monthIndex: newValue.idx)
    }
    .onChange(of: model.year) { newValue in
      print("Year: ", newValue)
      model.updateActiveYear(year: newValue.value)
    }
  }
}

struct CustomCalendar_Previews: PreviewProvider {
  @State static var date: Date = .now
  static var previews: some View {
    GeometryReader { geometry in
      CustomCalendar(model: .init(), geometry: geometry)
    }
  }
}
