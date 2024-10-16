//
//  TodayError.swift
//  Getting started with Today
//
//  Created by 강동영 on 10/16/24.
//

import Foundation

enum TodayError: LocalizedError {
    case failedReadingReminders
    
    var errorDescription: String? {
        switch self {
        case .failedReadingReminders:
            return NSLocalizedString(
                "Failed to read reminders.", comment: "failed reading reminders error description")
        }
    }
}
