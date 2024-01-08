//
//  ViewController.swift
//  Today
//
//  Created by İbrahim Bayram on 7.01.2024.
//

import UIKit


class ReminderListViewController: UICollectionViewController {
    
    var dataSoutce : DataSource!
    var reminders : [Reminder] = Reminder.sampleData
    var listStyle : ReminderListStyle = .all
    var filteredReminders : [Reminder] {
        return reminders.filter { listStyle.shouldInclude(date: $0.dueDate) }.sorted {
            $0.dueDate < $1.dueDate
        }
    }
    
    let listyStyleSegmentedControl = UISegmentedControl(items: [
        ReminderListStyle.all.name,ReminderListStyle.today.name,ReminderListStyle.future.name
    ])

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let listLayout = listLayout()
        collectionView.collectionViewLayout = listLayout
        
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        
        dataSoutce = DataSource(collectionView: collectionView, cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier : Reminder.ID) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPressAddbutton(_ :)))
        addButton.accessibilityLabel = NSLocalizedString("Add reminder", comment: "Add button accesibility label")
        navigationItem.rightBarButtonItem = addButton
        navigationItem.titleView = listyStyleSegmentedControl
        listyStyleSegmentedControl.selectedSegmentIndex = listStyle.rawValue
        listyStyleSegmentedControl.addTarget(self, action: #selector(listStyleDidChange(_ :)), for: .valueChanged)
        if #available(iOS 16, *) {
            navigationItem.style = .navigator
        }
        updateSnapshot()
        collectionView.dataSource = dataSoutce
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let id = filteredReminders[indexPath.item].id
        pushDetailViewController(with: id)
        return false
    }
    
    @objc func listStyleDidChange(_ sender : UISegmentedControl) {
        listStyle = ReminderListStyle(rawValue : sender.selectedSegmentIndex) ?? .all
        updateSnapshot()
    }
    
    func pushDetailViewController(with id: Reminder.ID) {
        let reminder = reminder(with: id)
        let viewController = ReminderViewController(reminder: reminder) { [weak self] reminder in
            self?.updateReminder(reminder)
            self?.updateSnapshot(reloading: [reminder.id])
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func makeSwipeActions(for indexPath : IndexPath?) -> UISwipeActionsConfiguration? {
        guard let indexPath = indexPath,let id = dataSoutce.itemIdentifier(for: indexPath) else { return nil }
        let deleteActionsTitle = NSLocalizedString("Delete", comment: "Delete action title")
        let deleteAction = UIContextualAction(style: .destructive, title: deleteActionsTitle) { [weak self] _, _, completion in
            self?.deleteReminder(with: id)
            self?.updateSnapshot()
            completion(false)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func listLayout() -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.showsSeparators = false
        listConfiguration.trailingSwipeActionsConfigurationProvider = makeSwipeActions
        listConfiguration.backgroundColor = .clear
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }


}

