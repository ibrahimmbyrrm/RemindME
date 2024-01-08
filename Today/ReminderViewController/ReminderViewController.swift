//
//  ReminderViewController.swift
//  Today
//
//  Created by İbrahim Bayram on 8.01.2024.
//

import UIKit

class ReminderViewController : UICollectionViewController {
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section,Row>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section,Row>
    
    var reminder : Reminder {
        didSet {
            onChange(reminder)
        }
    }
    var isAddingNewReminder = false
    var onChange : (Reminder) -> Void
    var workingReminder : Reminder
    private var dataSource : DataSource!
    
    init(reminder: Reminder,onChange : @escaping(Reminder)->Void) {
        self.reminder = reminder
        self.workingReminder = reminder
        self.onChange = onChange
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfiguration.showsSeparators = false
        listConfiguration.headerMode = .firstItemInSection
        let listLayout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        super.init(collectionViewLayout: listLayout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareDatasource()
        prepareNavigationController()
        updateSnapshotForViewing()
    }
    
    private func prepareDatasource() {
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        dataSource = DataSource(collectionView: collectionView) {
            (collectionView : UICollectionView,indexPath : IndexPath,row : Row) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: row)
        }
    }
    
    private func prepareNavigationController() {
        if #available(iOS 16, *) {
            navigationItem.style = .navigator
        }
        navigationItem.title = NSLocalizedString("Reminder", comment: "Reminder view controller title")
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            prepareForEditing()
        }else {
            if isAddingNewReminder {
                onChange(workingReminder)
            }else {
                prepareForViewing()
            }
        }
    }
    
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    @objc func didCancelEdit() {
        workingReminder = reminder
        setEditing(false, animated: true)
    }
    
    func prepareForViewing() {
        self.navigationItem.leftBarButtonItem = nil
        if workingReminder != reminder {
            reminder = workingReminder
        }
        updateSnapshotForViewing()
    }
    func prepareForEditing() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didCancelEdit))
        updateSnapshotForEditing()
    }
    
    func cellRegistrationHandler(cell : UICollectionViewListCell,indexPath : IndexPath, row : Row) {
        let section = section(for: indexPath)
        switch (section,row) {
        case (_,.header(let title)):
            cell.contentConfiguration = headerconfiguration(for: cell, with: title)
        case (.view,_):
            cell.contentConfiguration = defaultConfiguration(for: cell, at: row)
        case (.title,.editableText(let title)):
            cell.contentConfiguration = titleConfiguration(for: cell, with: title)
        case(.date,.editableDate(let date)):
            cell.contentConfiguration = dateConfiguration(for: cell, with: date)
        case (.notes,.editableText(let notes)):
            cell.contentConfiguration = notesconfiguration(for: cell, with: notes)
        default:
            fatalError("Unexpected combination of section and row")
        }
        cell.tintColor = .todayPrimaryTint
    }
    
    private func updateSnapshotForEditing() {
        var snapshot = Snapshot()
        snapshot.appendSections([.title, .date, .notes])
        snapshot.appendItems(
            [.header(Section.title.name), .editableText(reminder.title)], toSection: .title)
        snapshot.appendItems([.header(Section.date.name),.editableDate(reminder.dueDate)], toSection: .date)
        snapshot.appendItems([.header(Section.notes.name),.editableText(reminder.notes)], toSection: .notes)
        dataSource.apply(snapshot)
    }
    
    private func updateSnapshotForViewing() {
        var snapshot = Snapshot()
        snapshot.appendSections([.view])
        snapshot.appendItems([.header(""),.title,.date,.time,.notes],toSection: .view)
        dataSource.apply(snapshot)
    }
    
    private func section(for indexPath : IndexPath) -> Section {
        let sectionNumber = isEditing ? indexPath.section + 1 : indexPath.section
        guard let section = Section(rawValue: sectionNumber) else {
            fatalError("Unable to find matching section")
        }
        return section
    }
}
extension UICollectionViewListCell {
    func textFieldConfiguration() -> TextFieldContentView.Configuration {
        TextFieldContentView.Configuration()
    }
}
