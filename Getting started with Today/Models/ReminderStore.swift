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
    
    func requestAccess() async throws {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        
        switch status {
        case .authorized, .fullAccess, .writeOnly:
            return
        case .notDetermined:
            if #available(iOS 17.0, *) {
                let accessGuard = try await ekStore.requestFullAccessToReminders()
                guard accessGuard else {
                    throw TodayError.accessDenied
                }
            } else {
                let accessGuard = try await ekStore.requestAccess(to: .reminder)
                guard accessGuard else {
                    throw TodayError.accessDenied
                }
            }
        case .restricted:
            throw TodayError.accessRestricted
        case .denied:
            throw TodayError.accessDenied
        @unknown default:
            throw TodayError.unknown
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
    
    @discardableResult
    func save(_ reminder: Reminder) throws -> Reminder.ID {
        // 2. 미리 알림 액세스를 사용할 수 없는 경우 오류를 발생시키는 가드 문을 추가하십시오.
        guard isAvailable else {
            throw TodayError.accessDenied
        }
        // 3. ekReminder라는 상수를 선언합니다.
        let ekReminder: EKReminder
        // 4. read(with:)를 호출하고 결과를 상수에 할당하는 do 블록을 추가하십시오.
        do {
            ekReminder = try read(with: reminder.id)
        } catch {
            // 5. 이벤트 저장소에 새로운 알림을 생성하고 상수에 할당하는 캐치 블록을 추가하십시오.
            ekReminder = EKReminder(eventStore: ekStore)
        }
        // 6. 수신 알림의 값을 사용하여 ekReminder를 업데이트하십시오.
        ekReminder.update(using: reminder, in: ekStore)
        // 7. 알림을 저장하세요.
        try ekStore.save(ekReminder, commit: true)
        // 식별자를 반환합니다.
        return ekReminder.calendarItemIdentifier
    }
    
    func remove(with id: Reminder.ID) throws {
        // 2. 미리 알림 액세스를 사용할 수 없는 경우 오류를 발생시키는 가드 문을 추가하십시오.
        guard isAvailable else {
            throw TodayError.accessDenied
        }
        // 3. 식별자와 함께 알림을 읽으십시오.
        let ekReminder = try read(with: id)
        // 4. 상점에서 알림을 제거하십시오.
        try ekStore.remove(ekReminder, commit: true)
    }
    
    private func read(with id: Reminder.ID) throws -> EKReminder {
        guard let ekReminder = ekStore.calendarItem(withIdentifier: id) as? EKReminder else {
            throw TodayError.failedReadingCalendarItem
        }
        return ekReminder
    }
}
