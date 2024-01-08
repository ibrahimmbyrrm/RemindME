//
//  ReminderListViewontroller + DataSource.swift
//  Today
//
//  Created by İbrahim Bayram on 8.01.2024.
//

import UIKit

extension ReminderListViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Int,Reminder.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Reminder.ID>
    
    var reminderCompletedValue : String {
        NSLocalizedString("Completed", comment: "Reminder completed value")
    }
    var reminderNotCompletedValue : String {
        NSLocalizedString("Not Completed", comment: "Reminder not completed value")
    }
    
    func updateSnapshot(reloading idsThatchanged: [Reminder.ID] = []) {
        let ids = idsThatchanged.filter { id in filteredReminders.contains(where: { $0.id == id})}
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(filteredReminders.map({$0.id}))
        if !ids.isEmpty {
            snapshot.reloadItems(ids)
        }
        headerView?.progress = progress
        dataSoutce.apply(snapshot)
    }
    
    func cellRegistrationHandler(cell : UICollectionViewListCell,indexPath : IndexPath,id : Reminder.ID) {
        let reminder = reminder(with: id)
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = reminder.title
        contentConfiguration.secondaryText = reminder.dueDate.dayAndTimeText
        contentConfiguration.secondaryTextProperties.font = .preferredFont(forTextStyle: .caption1)
        cell.contentConfiguration = contentConfiguration
        cell.accessibilityCustomActions = [doneButtonAccesibilityAction(for: reminder)]
        cell.accessibilityValue = reminder.isComplete ? reminderCompletedValue : reminderNotCompletedValue
        var doneButtonConfiguration = doneButtonConfiguration(for: reminder)
        doneButtonConfiguration.tintColor = .todayListCellDoneButtonTint
        cell.accessories = [
            .customView(configuration: doneButtonConfiguration),
            .disclosureIndicator(displayed:.always)
        ]
        var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        backgroundConfiguration.backgroundColor = .todayListCellBackground
        cell.backgroundConfiguration = backgroundConfiguration
        
    }
    
    func doneButtonAccesibilityAction(for reminder: Reminder) -> UIAccessibilityCustomAction {
        let name = NSLocalizedString("Toggle completion", comment: "Reminder done button accesibility")
        let action = UIAccessibilityCustomAction(name: name) { [weak self] action in
            self?.completeReminder(with: reminder.id)
            return true
        }
        return action
    }
    
    func reminder(with id : Reminder.ID) -> Reminder {
        let index = reminders.indexOfReminder(with: id)
        return reminders[index]
    }
    
    func updateReminder(_ reminder : Reminder) {
        let index = reminders.indexOfReminder(with: reminder.id)
        reminders[index] = reminder
        print("reminder updated")
    }
    
    func addReminder(_ reminder : Reminder) {
        reminders.append(reminder)
    }
    
    func completeReminder(with id:Reminder.ID) {
        var reminder = reminder(with: id)
        reminder.isComplete.toggle()
        updateReminder(reminder)
        updateSnapshot(reloading: [id])
    }
    
    func deleteReminder(with id: Reminder.ID) {
        let index = reminders.indexOfReminder(with: id)
        reminders.remove(at: index)
    }
    
    private func doneButtonConfiguration(for reminder : Reminder) -> UICellAccessory.CustomViewConfiguration {
        let symbolName = reminder.isComplete ? "circle.fill" : "circle"
        let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
        let image = UIImage(systemName: symbolName, withConfiguration: symbolConfiguration)
        let button = ReminderDoneButton()
        button.id = reminder.id
        button.addTarget(self, action: #selector(didPressButton(_:)), for: .touchUpInside)
        button.setImage(image, for: .normal)
        return UICellAccessory.CustomViewConfiguration(customView: button, placement: .leading(displayed: .always))
    }
}
