//
//  EKEventStore+AsyncFetch.swift
//  Getting started with Today
//
//  Created by 강동영 on 10/16/24.
//

import EventKit
import Foundation

extension EKEventStore {
    func reminder(matching predicate: NSPredicate) async throws -> [EKReminder] {
        try await withCheckedThrowingContinuation { continuation in
            fetchReminders(matching: predicate) { reminders in
                if let reminders {
                    continuation.resume(returning: reminders)
                } else {
                    continuation.resume(throwing: TodayError.failedReadingReminders)
                }
            }
        }
    }
}
