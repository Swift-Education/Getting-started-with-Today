//
//  Reminder+EKReminder.swift
//  Getting started with Today
//
//  Created by 강동영 on 10/16/24.
//

import EventKit
import Foundation

extension Reminder {
    init(ekReminder: EKReminder) throws {
        guard let dueDate = ekReminder.alarms?.first?.absoluteDate else {
            throw TodayError.reminderHasNoDueDate
        }
        id = ekReminder.calendarItemIdentifier
        title = ekReminder.title
        self.dueDate = dueDate
        notes = ekReminder.notes
        isComplete = ekReminder.isCompleted
    }
}
