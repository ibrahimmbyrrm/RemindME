//
//  ReminderListViewModel.swift
//  Today
//
//  Created by İbrahim Bayram on 13.01.2024.
//

import UIKit

typealias DataSource = UICollectionViewDiffableDataSource<Int,Reminder.ID>
typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Reminder.ID>

protocol ReminderListViewModelInterface {
    var delegate : ReminderListViewInterface? {get set}
    var reminderStore : ReminderStore {get}
    var dataSource : DataSource! {get set}
    var reminders : [Reminder] {get set}
    var filteredReminders : [Reminder] {get}
    var progress : CGFloat {get}
    var listStyle : ReminderListStyle {get set}
    
    func viewDidLoad()
    func viewWillAppear()
    func updateSnapshot(reloading idsThatchanged: [Reminder.ID]?)
    func prepareReminderStore()
    func addReminder(_ reminder : Reminder)
    func completeReminder(with id : Reminder.ID)
    func deleteReminder(with id : Reminder.ID)
    func reminder(with id : Reminder.ID) -> Reminder
    func updateReminder(_ reminder : Reminder)
    func listStyleDidChange(_ index: Int)
    func collectionViewShouldSelectItem(at indexPath : IndexPath) -> Bool
}

final class ReminderListViewModel : ReminderListViewModelInterface {

    weak var delegate: ReminderListViewInterface?
    var reminderStore: ReminderStore { ReminderStore.shared}
    var dataSource: DataSource!
    var reminders: [Reminder] = []
    var listStyle: ReminderListStyle = .all
    var filteredReminders: [Reminder] {
        return reminders.filter { listStyle.shouldInclude(date: $0.dueDate) }.sorted {
            $0.dueDate < $1.dueDate
        }
    }
    var progress: CGFloat {
        let chunkSize = 1.0 / CGFloat(filteredReminders.count)
        let progress = filteredReminders.reduce(0.0) {
            let chunk = $1.isComplete ? chunkSize : 0
            return $0 + chunk
        }
        return progress
    }
    func collectionViewShouldSelectItem(at indexPath: IndexPath) -> Bool {
        let id = filteredReminders[indexPath.item].id
        delegate?.pushDetailViewController(with: id)
        return false
    }
    func listStyleDidChange(_ index: Int) {
        listStyle = ReminderListStyle(rawValue: index) ?? .all
        updateSnapshot(reloading: nil)
        delegate?.refreshBackground()
    }
    func viewDidLoad() {
        prepareReminderStore()
        if let collectionView = delegate?.ownerCollectionView {
            prepareCollectionViewDataFlow(collectionView: collectionView)
        }
        delegate?.prepareNavigationController()
        delegate?.prepareSegmentedControl()
        delegate?.prepareCollectionViewLayout()
        updateSnapshot(reloading: nil)
    }
    func viewWillAppear() {
        ///Done
        delegate?.refreshBackground()
    }
    func prepareReminderStore() {
        Task {
            do {
                try await reminderStore.requestAccess()
                reminders = try await reminderStore.readAll()
                NotificationCenter.default.addObserver(
                    self, selector: #selector(reminderStoreChaged(_:)), name: .EKEventStoreChanged, object: nil)
            } catch TodayError.accessDenied, TodayError.accessRestricted {
#if DEBUG
                reminders = Reminder.sampleData
#endif
            } catch {
                delegate?.showError(error)
            }
            updateSnapshot(reloading: nil)
        }
    }
    
    @objc private func reminderStoreChaged(_ notification : NSNotification) {
        Task {
            reminders = try await reminderStore.readAll()
            updateSnapshot(reloading: nil)
        }
    }
    
    func updateSnapshot(reloading idsThatchanged: [Reminder.ID]?) {
        var ids = [Reminder.ID]()
        if let idsThatchanged = idsThatchanged {
            ids = idsThatchanged.filter { id in filteredReminders.contains(where: { $0.id == id})}
        }
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(filteredReminders.map({$0.id}))
        if !ids.isEmpty {
            snapshot.reloadItems(ids)
        }
        
        delegate?.updateProgressView(progress)
        self.dataSource.apply(snapshot)
    }
    
    func updateReminder(_ reminder: Reminder) {
        do {
            try reminderStore.save(reminder)
            let index = reminders.indexOfReminder(with: reminder.id)
            reminders[index] = reminder
        }catch TodayError.accessDenied {
            
        }catch {
            delegate?.showError(error)
        }
    }
    func reminder(with id: Reminder.ID) -> Reminder {
        let index = reminders.indexOfReminder(with: id)
        return reminders[index]
    }
    func deleteReminder(with id: Reminder.ID) {
        do {
            try reminderStore.remove(with: id)
            let index = reminders.indexOfReminder(with: id)
            reminders.remove(at: index)
        }catch TodayError.accessDenied {
        }catch {
            delegate?.showError(error)
        }
        
    }
    func addReminder(_ reminder: Reminder) {
        var reminder = reminder
        do {
            let idFromStore = try reminderStore.save(reminder)
            reminder.id = idFromStore
            reminders.append(reminder)
        }catch TodayError.accessDenied {
            
        }catch {
            delegate?.showError(error)
        }
    }
    func completeReminder(with id: Reminder.ID) {
        var reminder = reminder(with: id)
        reminder.isComplete.toggle()
        updateReminder(reminder)
        updateSnapshot(reloading: [id])
    }
    func prepareCollectionViewDataFlow(collectionView : UICollectionView) {
        guard let handler = delegate?.cellRegistrationHandler,let supplementaryHandler = delegate?.suplementaryRegistrationHeader else {
            return
        }
        let cellRegistration = UICollectionView.CellRegistration(handler: handler)
        let headerRegistration = UICollectionView.SupplementaryRegistration(elementKind: ProgressHeaderView.elementKind, handler: supplementaryHandler)
        dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier : Reminder.ID) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
        dataSource.supplementaryViewProvider = { supplemanetayView,elementKind,indexPath in
            return self.delegate?.ownerCollectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }
}
