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

  @State private var isMonthYearPickerActive: Bool = false
  @State private var activeDatesPage: Int = 1

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
        if isMonthYearPickerActive {
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
        isMonthYearPickerActive = !isMonthYearPickerActive
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
          .rotationEffect(isMonthYearPickerActive ? .degrees(90) : .degrees(0))
      }
      .frame(height: 40, alignment: .leading)
    }
  }

  private func monthNavigationButton() -> some View {
    HStack(spacing: 10) {
      let iconSize = CGSize(width: 40, height: 40)
      let font = Font.system(size: 18, weight: .bold, design: .rounded)
      Button {
        let newIndex = model.monthYear.month - 1
        let isPreviousYear = newIndex < 0
        let monthIndex = isPreviousYear ? 11 : newIndex
        let updatedYear = isPreviousYear ? model.monthYear.year - 1 : model.monthYear.year
        model.monthYear = .init(month: monthIndex, year: updatedYear)
        activeDatesPage = 0
      } label: {
        Image(systemName: "chevron.left")
          .font(font)
          .frame(width: iconSize.width, height: iconSize.height, alignment: .center)
      }

      Button {
        let newIndex = model.monthYear.month + 1
        let isNewYear = newIndex > 11
        let monthIndex = isNewYear ? 0 : newIndex
        let updatedYear = isNewYear ? model.monthYear.year + 1 : model.monthYear.year
        model.monthYear = .init(month: monthIndex, year: updatedYear)
        activeDatesPage = 2
      } label: {
        Image(systemName: "chevron.right")
          .font(font)
          .frame(width: iconSize.width, height: iconSize.height, alignment: .center)
      }
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
    let daysContainerHeight = dayWidth * 6
    ScrollViewReader { proxy in
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 0) {
          let dates = [model.datesTempLeft, model.dates, model.datesTempRight]
          //let colors = [Color.gray, Color.green, Color.blue] // TODO: color debugger
          ForEach(0...2, id: \.self) { idx in
            let dateCollection = dates[idx]
            drawDateCollectionViewStack(dateCollection: dateCollection, contentWidth: contentWidth, daysContainerHeight: daysContainerHeight)
            //.background(colors[idx])
          }
        }
        .background {
          GeometryReader { geometry in
            Color.clear
              .preference(key: ScrollViewOffsetKey.self,
                          value: abs(geometry.frame(in: .named("contentOffset")).origin.x))
          }
        }
      }
      .frame(width: geometry.size.width, height: daysContainerHeight, alignment: .center)
      .onAppear {
        proxy.scrollTo(activeDatesPage, anchor: .center)
      }
      .onChange(of: activeDatesPage) { newValue in
        if newValue == 1 {
          proxy.scrollTo(newValue, anchor: .center)
          model.generateTempCollectionPage()
        } else {
          withAnimation {
            proxy.scrollTo(newValue, anchor: .center)
          }
        }
      }
    }
    .coordinateSpace(name: "contentOffset")
    .onPreferenceChange(ScrollViewOffsetKey.self) { value in
      let contentOffsetIndex = value / geometry.size.width
      if contentOffsetIndex == 0 || contentOffsetIndex == 2 {
        activeDatesPage = 1
      }
    }
  }

  private func drawDateCollectionViewStack(dateCollection: [CustomCalendarModel.DayRowModel], contentWidth: CGFloat, daysContainerHeight: CGFloat) -> some View {
    LazyVStack(spacing: 0) {
      let range = 0..<dateCollection.count
      ForEach(range, id: \.self) { i in
        let collection = dateCollection[i]
        drawDaysOfTheMonthRowViewStack(contentWidth: contentWidth, rowModel: collection)
      }
    }
    .frame(width: geometry.size.width, height: daysContainerHeight, alignment: .top)
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
              .foregroundColor(day.isSelected ? .white : day.isCurrentDate ? .blue : .black)
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
                        monthYear: $model.monthYear,
                        geometry: geometry)
    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
    .background(.white)
    .onChange(of: model.monthYear) { newValue in
      print("MonthYear: ", newValue)
      model.generateTempCollectionPage()
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
