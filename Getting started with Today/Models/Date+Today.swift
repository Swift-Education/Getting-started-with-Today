//
//  Date+Today.swift
//  Getting started with Today
//
//  Created by 강동영 on 10/11/24.
//

import Foundation

extension Date {
    var dayAndTimeText: String {
        // 기본 스타일을 사용하여 현재 로케일의 날짜와 시간의 문자열 표현을 포맷합니다. 날짜 스타일에 대해 .ommitted를 전달하면 시간 구성 요소의 문자열만 생성됩니다.
        let timeText = formatted(date: .omitted, time: .shortened)
        // 현재 달력 날짜에 있는지 여부를 테스트하는 if-else 문
        if Locale.current.calendar.isDateInToday(self) {
            // 문자열의 "오늘" 부분을 현지화
            // 각 문자열에 대한 항목과 번역이 포함된 번역 테이블을 앱에 포함
            let timeFormat = NSLocalizedString("Today at %@", comment: "Today at time format string")
            return String(format: timeFormat, timeText)
        } else {
            let dateText = formatted(.dateTime.month(.abbreviated).day())
            let dateAndTimeFormat = NSLocalizedString("%@ at %@", comment: "Date and time format string")
                        return String(format: dateAndTimeFormat, dateText, timeText)
        }
    }
    
    var dayText: String {
        if Locale.current.calendar.isDateInToday(self) {
            return NSLocalizedString("Today", comment: "Today due date description")
        } else {
            return formatted(.dateTime.month().day().weekday(.wide))
        }
    }
}
