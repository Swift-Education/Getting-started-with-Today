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
    
    func updateSnapshot(reloading ids: [Reminder.ID] = []) {
        var snapshot = Snapshot()
        snapshot.appendSections([0]) // 섹션 추가하기
        snapshot.appendItems(reminders.map { $0.id }) // 아이템 추가하기
        if !ids.isEmpty {
            snapshot.reloadItems(ids)
        }
        dataSource.apply(snapshot)
    }
    
    func cellRegistrationHandler(
        cell: UICollectionViewListCell, indexPath: IndexPath, id: Reminder.ID
    ) {
        let remider = reminder(with: id)
        // defaultContentConfiguration()은 미리 정의된 시스템 스타일로 콘텐츠 구성을 생성합니다.
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = remider.title
        contentConfiguration.secondaryText = remider.dueDate.dayAndTimeText
        contentConfiguration.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .caption1)
        cell.contentConfiguration = contentConfiguration
        
        var doneButtonConfiguration = doneButtonConfiguration(for: remider)
        doneButtonConfiguration.tintColor = .todayListCellDoneButtonTint
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
