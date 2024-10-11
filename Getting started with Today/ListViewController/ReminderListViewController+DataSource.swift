//
//  ReminderListViewController+DataSource.swift
//  Getting started with Today
//
//  Created by 강동영 on 10/11/24.
//

import UIKit

extension ReminderListViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, String>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, String>
    
    func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, id: String) {
        let remider = Reminder.sampleData[indexPath.item]
        // defaultContentConfiguration()은 미리 정의된 시스템 스타일로 콘텐츠 구성을 생성합니다.
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = remider.title
        contentConfiguration.secondaryText = remider.dueDate.dayAndTimeText
        contentConfiguration.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .caption1)
        cell.contentConfiguration = contentConfiguration
    }
}
