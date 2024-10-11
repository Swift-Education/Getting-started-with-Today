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
    
    func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, id: Reminder.ID) {
        let remider = reminders[indexPath.item]
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
    
    // 미리 알림 셀의 앞면에 완료 버튼 셀 액세서리를 추가
    // 또한 체크 표시, 재정렬, 삭제 및 공개 표시 셀 액세서리를 목록 셀에 추가할 수 있음
    // CustomViewConfiguration을 반환하는 메서드
    private func doneButtonConfiguration(for reminder: Reminder) -> UICellAccessory.CustomViewConfiguration {
        
        
        let symbolName = reminder.isComplete ? "circle.fill" : "circle"
        let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
        let image = UIImage(systemName: symbolName, withConfiguration: symbolConfiguration)
        let button = UIButton()
        button.setImage(image, for: .normal)
        
        // 셀 액세서리가 셀의 콘텐츠 보기 외부 셀의 앞 leading 또는 trailing에 나타나는지 정의
        return UICellAccessory.CustomViewConfiguration(
            customView: button, placement: .leading(displayed: .always))
    }
}
