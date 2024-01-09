//
//  ViewController.swift
//  Today
//
//  Created by İbrahim Bayram on 7.01.2024.
//

import UIKit


class ReminderListViewController: UICollectionViewController {
    
    var reminderStore : ReminderStore { ReminderStore.shared }
    var dataSoutce : DataSource!
    var reminders : [Reminder] = []
    var listStyle : ReminderListStyle = .all
    var filteredReminders : [Reminder] {
        return reminders.filter { listStyle.shouldInclude(date: $0.dueDate) }.sorted {
            $0.dueDate < $1.dueDate
        }
    }
    var headerView : ProgressHeaderView?
    
    var progress : CGFloat {
        let chunkSize = 1.0 / CGFloat(filteredReminders.count)
        let progress = filteredReminders.reduce(0.0) {
            let chunk = $1.isComplete ? chunkSize : 0
            return $0 + chunk
        }
        return progress
    }
    
    let listyStyleSegmentedControl = UISegmentedControl(items: [
        ReminderListStyle.all.name,ReminderListStyle.today.name,ReminderListStyle.future.name
    ])
    //MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareReminderStore()
        prepareCollectionViewLayout()
        prepareCollectionViewDataFlow()
        prepareNavigationController()
        prepareSegmentedControl()
        updateSnapshot()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshBackground()
    }
    //MARK: - Overriden CollectionView Functions
    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard elementKind == ProgressHeaderView.elementKind,let progressView = view as? ProgressHeaderView else {return}
        progressView.progress = progress
    }
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let id = filteredReminders[indexPath.item].id
        pushDetailViewController(with: id)
        return false
    }
    //MARK: - Initial Preperation Methods
    private func prepareSegmentedControl() {
        listyStyleSegmentedControl.selectedSegmentIndex = listStyle.rawValue
        listyStyleSegmentedControl.addTarget(self, action: #selector(listStyleDidChange(_ :)), for: .valueChanged)
    }
    
    func prepareReminderStore() {
        Task {
            do {
                try await reminderStore.requestAccess()
                reminders = try await reminderStore.readAll()
                NotificationCenter.default.addObserver(
                    self, selector: #selector(eventStoreChanged(_:)), name: .EKEventStoreChanged, object: nil)
            } catch TodayError.accessDenied, TodayError.accessRestricted {
                #if DEBUG
                reminders = Reminder.sampleData
                #endif
            } catch {
                showError(error)
            }
            updateSnapshot()
        }
    }
    
    private func prepareCollectionViewLayout() {
        collectionView.backgroundColor = .todayGradientFutureBegin
        let listLayout = listLayout()
        collectionView.collectionViewLayout = listLayout
        collectionView.dataSource = dataSoutce
    }
    
    private func prepareCollectionViewDataFlow() {
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        let headerRegistration = UICollectionView.SupplementaryRegistration(elementKind: ProgressHeaderView.elementKind, handler: suplementaryRegistrationHeader)
        dataSoutce = DataSource(collectionView: collectionView, cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier : Reminder.ID) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
        dataSoutce.supplementaryViewProvider = { supplemanetayView,elementKind,indexPath in
            return self.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }
    
    private func prepareNavigationController() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPressAddbutton(_ :)))
        addButton.accessibilityLabel = NSLocalizedString("Add reminder", comment: "Add button accesibility label")
        navigationItem.rightBarButtonItem = addButton
        navigationItem.titleView = listyStyleSegmentedControl
        if #available(iOS 16, *) {
            navigationItem.style = .navigator
        }
    }
    
    func reminderStoreChanged() {
        Task {
            reminders = try await reminderStore.readAll()
            updateSnapshot()
        }
    }
    
    func showError(_ error : Error) {
        let alertTitle = NSLocalizedString("Error", comment: "Error alert title")
        let alert = UIAlertController(title: alertTitle, message: error.localizedDescription, preferredStyle: .alert)
        let actionTitle = NSLocalizedString("OK", comment: "Alert OK button title")
        alert.addAction(UIAlertAction(title: actionTitle, style: .default,handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }))
        present(alert, animated: true)
    }
    
    @objc func listStyleDidChange(_ sender : UISegmentedControl) {
        listStyle = ReminderListStyle(rawValue : sender.selectedSegmentIndex) ?? .all
        updateSnapshot()
        refreshBackground()
    }
    
    func refreshBackground() {
        collectionView.backgroundView = nil
        let backgroundView = UIView()
        let gradientLayer = CAGradientLayer.gradiendLayer(for: listStyle, in: collectionView.frame)
        backgroundView.layer.addSublayer(gradientLayer)
        collectionView.backgroundView = backgroundView
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
        listConfiguration.headerMode = .supplementary
        listConfiguration.trailingSwipeActionsConfigurationProvider = makeSwipeActions
        listConfiguration.backgroundColor = .clear
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    private func suplementaryRegistrationHeader(progressView : ProgressHeaderView,elementKind : String,indexPath : IndexPath) {
        headerView = progressView
    }
    
    
}

