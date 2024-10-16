//
//  ReminderListViewController+DataSource.swift
//  Getting started with Today
//
//  Created by 강동영 on 10/11/24.
//

import UIKit

extension ReminderListViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Reminder.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Reminder.ID>
    
    // 버튼에 접근성 값을 추가할 것입니다. 각 알림의 완료 상태에 대한 현지화된 문자열을 계산하는 것으로 시작하십시오.
    var reminderCompletedValue: String {
        NSLocalizedString("Completed", comment: "Reminder completed value")
    }
    var reminderNotCompletedValue: String {
        NSLocalizedString("Not completed", comment: "Reminder not completed value")
    }
    
    private var reminderStore: ReminderStore { ReminderStore.shared }
    
    func updateSnapshot(reloading idsThatChanged: [Reminder.ID] = []) {
        let ids = idsThatChanged.filter { id in filteredReminders.contains(where: { $0.id == id })}
        var snapshot = Snapshot()
        snapshot.appendSections([0]) // 섹션 추가하기
        snapshot.appendItems(filteredReminders.map { $0.id }) // 아이템 추가하기
        if !ids.isEmpty {
            snapshot.reloadItems(ids)
        }
        dataSource.apply(snapshot)
        headerView?.progress = progress
    }
    
    func cellRegistrationHandler(
        cell: UICollectionViewListCell, indexPath: IndexPath, id: Reminder.ID
    ) {
        let reminder = reminder(with: id)
        // defaultContentConfiguration()은 미리 정의된 시스템 스타일로 콘텐츠 구성을 생성합니다.
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = reminder.title
        contentConfiguration.secondaryText = reminder.dueDate.dayAndTimeText
        contentConfiguration.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .caption1)
        cell.contentConfiguration = contentConfiguration
        
        var doneButtonConfiguration = doneButtonConfiguration(for: reminder)
        doneButtonConfiguration.tintColor = .todayListCellDoneButtonTint
        // 셀 등록 핸들러에서 셀의 접근성 사용자 지정 동작 배열을 사용자 지정 동작의 인스턴스로 설정
        cell.accessibilityCustomActions = [doneButtonAccessibilityAction(for: reminder)]
        // 셀 등록 핸들러에서 올바른 현지화된 문자열을 셀의 접근성 값에 할당
        cell.accessibilityValue = reminder.isComplete ? reminderCompletedValue : reminderNotCompletedValue
        cell.accessories = [
            .customView(configuration: doneButtonConfiguration), .disclosureIndicator(displayed: .always)
        ]
        
        var backgroundConfiguration: UIBackgroundConfiguration!
        if #available(iOS 18.0, *) {
            backgroundConfiguration = UIBackgroundConfiguration.listCell()
        } else {
            backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        }
        
        // 정적 변수가 있는 UIColor의 확장
        backgroundConfiguration.backgroundColor = .todayListCellBackground
        cell.backgroundConfiguration = backgroundConfiguration
    }
    
    func reminder(with id: Reminder.ID) -> Reminder {
        let index = reminders.indexOfReminder(with: id)
        return reminders[index]
    }
    
    func updateReminder(_ reminder: Reminder) {
        let index = reminders.indexOfReminder(with: reminder.id)
        reminders[index] = reminder
    }
    
    func completeReminder(with id: Reminder.ID) {
        var reminder = reminder(with: id)
        reminder.isComplete.toggle()
        updateReminder(reminder)
        updateSnapshot(reloading: [id])
    }
    
    func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
    }
    
    func deleteReminder(withId id: Reminder.ID) {
        let index = reminders.indexOfReminder(with: id)
        reminders.remove(at: index)
    }
    
    func prepareReminderStore() {
        Task {
            do {
                try await reminderStore.requestAccess()
                reminders = try await reminderStore.readAll()
            } catch TodayError.accessDenied, TodayError.accessRestricted {
                #if DEBUG
                reminders = Reminder.sampleData
                #endif
            } catch {
                showError(error)
            }
            updateSnapshot()
        }
    }
    
    func reminderStoreChanged() {
        Task {
            do {
                reminders = try await reminderStore.readAll()
                NotificationCenter.default.addObserver(
                    self, selector: #selector(eventStoreChanged(_:)), name: .EKEventStoreChanged, object: nil)
            } catch TodayError.accessDenied, TodayError.accessRestricted {
                #if DEBUG
                reminders = Reminder.sampleData
                #endif
            } catch {
                showError(error)
            }
            updateSnapshot()
        }
    }
    
    private func doneButtonAccessibilityAction(for reminder: Reminder) -> UIAccessibilityCustomAction {
        // VoiceOver는 개체에 대한 작업을 사용할 수 있을 때 사용자에게 경고합니다. 사용자가 옵션을 듣기로 결정하면 VoiceOver는 각 작업의 이름을 읽습니다.
        let name = NSLocalizedString(
                    "Toggle completion", comment: "Reminder done button accessibility label")
        // 기본적으로 클로저는 내부에서 사용하는 외부 값에 대한 강력한 참조를 생성합니다. 뷰 컨트롤러에 대한 약한 참조를 지정하면 순환 참조가 방지됩니다.
        let action = UIAccessibilityCustomAction(name: name) { [weak self] action in
            self?.completeReminder(with: reminder.id)
            return true
        }
        return action
    }
    
    // 미리 알림 셀의 앞면에 완료 버튼 셀 액세서리를 추가
    // 또한 체크 표시, 재정렬, 삭제 및 공개 표시 셀 액세서리를 목록 셀에 추가할 수 있음
    // CustomViewConfiguration을 반환하는 메서드
    private func doneButtonConfiguration(for reminder: Reminder) -> UICellAccessory.CustomViewConfiguration {
        let symbolName = reminder.isComplete ? "circle.fill" : "circle"
        let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
        let image = UIImage(systemName: symbolName, withConfiguration: symbolConfiguration)
        let button = ReminderDoneButton()
        // 컴파일하는 동안, 시스템은 대상인 ReminderListViewController(self)에 didPressDoneButton(_:) 메서드가 있는지 확인합니다.
        button.addTarget(self, action: #selector(didPressDoneButton(_:)), for: .touchUpInside)
        button.id = reminder.id
        button.setImage(image, for: .normal)
        
        // 셀 액세서리가 셀의 콘텐츠 보기 외부 셀의 앞 leading 또는 trailing에 나타나는지 정의
        return UICellAccessory.CustomViewConfiguration(
            customView: button, placement: .leading(displayed: .always))
    }
}
