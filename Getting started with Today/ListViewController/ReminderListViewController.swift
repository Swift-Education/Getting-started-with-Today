//
//  ReminderListViewController.swift
//  Getting started with Today
//
//  Created by 강동영 on 10/8/24.
//

import UIKit

class ReminderListViewController: UICollectionViewController {
    var dataSource: DataSource!
    var reminders: [Reminder] = Reminder.sampleData
    var listStyle: ReminderListStyle = .today
    var filteredReminders: [Reminder] {
        return reminders.filter { listStyle.shouldInclude(date: $0.dueDate) }.sorted {
            $0.dueDate < $1.dueDate
        }
    }
    let listStyleSegmentControl = UISegmentedControl(items: [
        ReminderListStyle.today.name, ReminderListStyle.future.name, ReminderListStyle.all.name
    ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let listLayout = listLayout()
        collectionView.collectionViewLayout = listLayout
        
        // CellRegistration은 셀의 내용과 모양을 구성하는 방법을 지정합니다.
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, itemIdentifier: Reminder.ID) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(didPressAddButton(_:)))
        addButton.accessibilityLabel = NSLocalizedString(
            "Add reminder", comment: "Add button accessibility label")
        navigationItem.rightBarButtonItem = addButton
        
        listStyleSegmentControl.selectedSegmentIndex = listStyle.rawValue
        listStyleSegmentControl.addTarget(
            self, action: #selector(didChangeListStyle(_:)), for: .valueChanged)
        navigationItem.titleView = listStyleSegmentControl
        
        if #available(iOS 16, *) {
            navigationItem.style = .navigator
        }
        updateSnapshot()
        
        collectionView.dataSource = dataSource
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let id = filteredReminders[indexPath.item].id
        pushDetailViewForReminder(with: id)
        // 사용자가 선택한 항목으로 탭한 항목이 표시되지 않으므로 false를 반환합니다. 대신, 당신은 그 목록 항목에 대한 세부 보기로 전환할 것입니다.
    }
    
    func pushDetailViewForReminder(with id: Reminder.ID) {
        let reminder = reminder(with: id)
        // 검색한 리마인더를 ReminderViewController의 새 인스턴스에 주입합니다.
        let viewController = ReminderViewController(reminder: reminder, onChange: { [weak self] reminder in
            self?.updateReminder(reminder)
            self?.updateSnapshot(reloading: [reminder.id])
        })
        // 뷰 컨트롤러가 현재 내비게이션 컨트롤러에 내장되어 있는 경우, 내비게이션 컨트롤러에 대한 참조는 선택적 내비게이션 컨트롤러 속성에 저장됩니다.
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func listLayout() -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.showsSeparators = false
        listConfiguration.trailingSwipeActionsConfigurationProvider = makeSwipeActions
        listConfiguration.backgroundColor = .clear
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    private func makeSwipeActions(for indexPath: IndexPath?) -> UISwipeActionsConfiguration? {
        guard let indexPath = indexPath, let id = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        let deleteActionTitle = NSLocalizedString("Delete", comment: "Delete action title")
        let deleteAction = UIContextualAction(style: .destructive, title: deleteActionTitle, handler: { [weak self] _, _, completion in
            self?.deleteReminder(withId: id)
            self?.updateSnapshot()
            completion(false)
        })
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

