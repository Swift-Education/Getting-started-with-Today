//
//  ReminderListViewController.swift
//  Getting started with Today
//
//  Created by 강동영 on 10/8/24.
//

import UIKit

class ReminderListViewController: UICollectionViewController {
    var dataSource: DataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let listLayout = listLayout()
        collectionView.collectionViewLayout = listLayout
        
        // CellRegistration은 셀의 내용과 모양을 구성하는 방법을 지정합니다.
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
        
        var snapshot = Snapshot()
        snapshot.appendSections([0]) // 섹션 추가하기
        snapshot.appendItems(Reminder.sampleData.map { $0.title }) // 아이템 추가하기
        dataSource.apply(snapshot)
        
        collectionView.dataSource = dataSource
    }
    
    private func listLayout() -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.showsSeparators = false
        listConfiguration.backgroundColor = .clear
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
}

