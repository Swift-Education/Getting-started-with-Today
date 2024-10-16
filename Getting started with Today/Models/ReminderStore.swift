//
//  ReminderStore.swift
//  Getting started with Today
//
//  Created by 강동영 on 10/16/24.
//

import EventKit
import Foundation

// final class에서는 메서드를 재정의할 수 없습니다. 하위클래스로 상속 관계를 맺을 수 없습니다.
final class ReminderStore {
    // 2. 앱 전체에서 사용할 수 있는 클래스의 단일 인스턴스를 만들 수 있습니다.
    static let shared = ReminderStore()
    
    // 3. 새로운 EKEventStore를 할당
    private let ekStore = EKEventStore()
    
    // 4. 알림 승인 상태가 .authorized인 경우 true를 반환
    var isAvailable: Bool {
        if #available(iOS 17.0, *) {
            return EKEventStore.authorizationStatus(for: .reminder) == .fullAccess || EKEventStore.authorizationStatus(for: .reminder) == .writeOnly
        } else {
            return EKEventStore.authorizationStatus(for: .reminder) == .authorized
        }
    }
    
    func readAll() async throws -> [Reminder] {
        guard isAvailable else {
            throw TodayError.accessDenied
        }
        let predicate = ekStore.predicateForReminders(in: nil)
        let ekReminders = try await ekStore.reminder(matching: predicate)
        let reminders: [Reminder] = try ekReminders.compactMap { ekReminder in
            do {
                return try Reminder(ekReminder: ekReminder)
            } catch TodayError.reminderHasNoDueDate{
                return nil
            }
        }
        return reminders
    }
}
