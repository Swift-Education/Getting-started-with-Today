//
//  ReminderViewController.swift
//  Getting started with Today
//
//  Created by 강동영 on 10/11/24.
//

import UIKit

class ReminderViewController: UICollectionViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Row>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Row>
    
    var reminder: Reminder
    var dataSource: DataSource!
    
    init(reminder: Reminder) {
        self.reminder = reminder
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfiguration.showsSeparators = false
        let listLayout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        super.init(collectionViewLayout: listLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // CellRegistration은 셀의 내용과 모양을 구성하는 방법을 지정합니다.
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, itemIdentifier: Row) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
        
        updateSnapshot()
        
        collectionView.dataSource = dataSource
    }
    
    func cellRegistrationHandler(
        cell: UICollectionViewListCell, indexPath: IndexPath, row: Row
    ) {
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = text(for: row)
        contentConfiguration.textProperties.font = UIFont.preferredFont(forTextStyle: row.textStyle)
        contentConfiguration.image = row.image
        cell.contentConfiguration = contentConfiguration
        cell.tintColor = .todayPrimaryTint
    }
    
    func text(for row: Row) -> String? {
        switch row {
        case .date: return reminder.dueDate.dayText
        case .notes: return reminder.notes
        case .time: return reminder.dueDate.formatted(date: .omitted, time: .shortened)
        case .title: return reminder.title
        }
    }
    
    func updateSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([0]) // 섹션 추가하기
        // 아이템 추가하기
        snapshot.appendItems([Row.title, Row.date, Row.time, Row.notes], toSection: 0)
        dataSource.apply(snapshot)
    }
}
