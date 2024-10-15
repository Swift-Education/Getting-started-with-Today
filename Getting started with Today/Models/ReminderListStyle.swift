//
//  ReminderListStyle.swift
//  Getting started with Today
//
//  Created by 강동영 on 10/15/24.
//

import Foundation

enum ReminderListStyle: Int {
    case today
    case future
    case all
    
    func shouldInclude(date: Date) -> Bool {
        let isInToday = Locale.current.calendar.isDateInToday(date)
        switch self {
        case .today:
            return isInToday
        case .future:
            return (date > Date.now) && !isInToday
        case .all:
            return true
        }
    }
}
