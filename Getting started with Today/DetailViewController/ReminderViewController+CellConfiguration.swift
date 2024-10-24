//
//  ReminderViewController+CellConfiguration.swift
//  Getting started with Today
//
//  Created by 강동영 on 10/15/24.
//

import UIKit


extension ReminderViewController {
    func defaultConfiguration(for cell: UICollectionViewListCell, at row: Row)
    -> UIListContentConfiguration
    {
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = text(for: row)
        contentConfiguration.textProperties.font = UIFont.preferredFont(forTextStyle: row.textStyle)
        contentConfiguration.image = row.image
        return contentConfiguration
    }
    
    func headerConfiguration(for cell: UICollectionViewListCell, with title: String)
    -> UIListContentConfiguration
    {
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = title
        return contentConfiguration
    }
    
    func titleConfiguration(for cell: UICollectionViewListCell, with title: String?)
    -> TextFieldContentView.Configuration
    {
        var contentConfiguration = cell.textFieldConfiguration()
        contentConfiguration.text = title
        contentConfiguration.onChange = { [weak self] title in
            self?.worikingReminder.title = title
        }
        return contentConfiguration
    }
    
    func dateConfiguration(for cell: UICollectionViewListCell, with date: Date)
    -> DatePickerContentView.Configuration
    {
        var contentConfiguration = cell.datePickerConfiguration()
        contentConfiguration.date = date
        contentConfiguration.onchange = { [weak self] date in
            self?.worikingReminder.dueDate = date
        }
        return contentConfiguration
    }
    
    func notesConfiguration(for cell: UICollectionViewListCell, with notes: String?)
    -> TextViewContentView.Configuration
    {
        var contentConfiguration = cell.textViewConfiguration()
        contentConfiguration.text = notes
        contentConfiguration.onchanged = { [weak self] notes in
            self?.worikingReminder.notes = notes
        }
        return contentConfiguration
    }
    
    func text(for row: Row) -> String? {
        switch row {
        case .date: return reminder.dueDate.dayText
        case .notes: return reminder.notes
        case .time: return reminder.dueDate.formatted(date: .omitted, time: .shortened)
        case .title: return reminder.title
        default: return nil
        }
    }
}

