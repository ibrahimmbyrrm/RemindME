//
//  ReminderListViewController+CellConfiguration.swift
//  Today
//
//  Created by İbrahim Bayram on 8.01.2024.
//

import UIKit

extension ReminderViewController {
    func defaultConfiguration(for cell : UICollectionViewListCell,at row : Row) -> UIListContentConfiguration {
        var contenConfiguration = cell.defaultContentConfiguration()
        contenConfiguration.text = text(for: row)
        contenConfiguration.textProperties.font = UIFont.preferredFont(forTextStyle: row.textStyle)
        contenConfiguration.image = row.image
        return contenConfiguration
    }
    func headerconfiguration(for cell : UICollectionViewListCell,with title : String) -> UIListContentConfiguration {
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = title
        return contentConfiguration
    }
    func titleConfiguration(for cell : UICollectionViewListCell,with title : String?) -> TextFieldContentView.Configuration {
        var contentConfiguration = cell.textFieldConfiguration()
        contentConfiguration.text = title
        contentConfiguration.onChange = { [weak self] newTitle in
            self?.workingReminder.title = newTitle
        }
        return contentConfiguration
    }
    func dateConfiguration(for cell : UICollectionViewListCell,with date: Date) -> DatePickerContentView.Configuration {
        var contentConfiguration = cell.datePickerConfiguration()
        contentConfiguration.date = date
        contentConfiguration.onChange = { [weak self] newDate in
            self?.workingReminder.dueDate = newDate
        }
        return contentConfiguration
        
    }
    func notesconfiguration(for cell : UICollectionViewListCell,with note: String?) -> TextViewContentView.Configuration {
        var contentConfiguration = cell.textViewConfiguration()
        contentConfiguration.text = note
        contentConfiguration.onChange = { [weak self] newNote in
            self?.workingReminder.notes = newNote
        }
        return contentConfiguration
    }
    private func text(for row : Row) -> String? {
        switch row {
        case .date: return reminder.dueDate.dayText
        case .notes: return reminder.notes
        case .title: return reminder.title
        case .time: return reminder.dueDate.formatted(date: .omitted, time: .shortened)
        default: return nil
        }
    }
}
