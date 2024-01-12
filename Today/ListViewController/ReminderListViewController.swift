//
//  ViewController.swift
//  Today
//
//  Created by İbrahim Bayram on 7.01.2024.
//

import UIKit

protocol ReminderListViewInterface : AnyObject {
    var ownerCollectionView : UICollectionView! {get}
    func updateProgressView(_ progress : CGFloat)
    func showError(_ error : Error)
    func refreshBackground()
    func prepareCollectionViewLayout()
    func prepareSegmentedControl()
    func cellRegistrationHandler(cell : UICollectionViewListCell,indexPath : IndexPath,id : Reminder.ID)
    func suplementaryRegistrationHeader(progressView : ProgressHeaderView,elementKind : String,indexPath : IndexPath)
    func prepareNavigationController()
    func pushDetailViewController(with id: Reminder.ID)
}


class ReminderListViewController: UICollectionViewController,ReminderListViewInterface {

    var ownerCollectionView: UICollectionView! {
        return collectionView
    }
    var headerView : ProgressHeaderView?

    let listyStyleSegmentedControl = UISegmentedControl(items: [
        ReminderListStyle.all.name,ReminderListStyle.today.name,ReminderListStyle.future.name
    ])
    var viewModel : ReminderListViewModelInterface = ReminderListViewModel()
    //MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        viewModel.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }
    //MARK: - Overriden CollectionView Functions
    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard elementKind == ProgressHeaderView.elementKind,let progressView = view as? ProgressHeaderView else {return}
        progressView.progress = viewModel.progress
    }
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        viewModel.collectionViewShouldSelectItem(at: indexPath)
    }
    //MARK: - Initial Preperation Methods
    func prepareSegmentedControl() {
        listyStyleSegmentedControl.selectedSegmentIndex = viewModel.listStyle.rawValue
        listyStyleSegmentedControl.addTarget(self, action: #selector(listStyleDidChange(_ :)), for: .valueChanged)
    }

    func prepareCollectionViewLayout() {
        collectionView.backgroundColor = .todayGradientFutureBegin
        let listLayout = listLayout()
        collectionView.collectionViewLayout = listLayout
        collectionView.dataSource = viewModel.dataSource
    }
    
    func prepareNavigationController() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPressAddbutton(_ :)))
        addButton.accessibilityLabel = NSLocalizedString("Add reminder", comment: "Add button accesibility label")
        navigationItem.rightBarButtonItem = addButton
        navigationItem.titleView = listyStyleSegmentedControl
        if #available(iOS 16, *) {
            navigationItem.style = .navigator
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
    
    func refreshBackground() {
        collectionView.backgroundView = nil
        let backgroundView = UIView()
        let gradientLayer = CAGradientLayer.gradiendLayer(for: viewModel.listStyle, in: collectionView.frame)
        backgroundView.layer.addSublayer(gradientLayer)
        collectionView.backgroundView = backgroundView
    }
    
    func updateProgressView(_ progress: CGFloat) {
        headerView?.progress = progress
    }
    
    func pushDetailViewController(with id: Reminder.ID) {
        let reminder = viewModel.reminder(with: id)
        let viewController = ReminderViewController(reminder: reminder) { [weak self] reminder in
            self?.viewModel.updateReminder(reminder)
            self?.viewModel.updateSnapshot(reloading: [reminder.id])
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func makeSwipeActions(for indexPath : IndexPath?) -> UISwipeActionsConfiguration? {
        guard let indexPath = indexPath,let id = viewModel.dataSource.itemIdentifier(for: indexPath) else { return nil }
        let deleteActionsTitle = NSLocalizedString("Delete", comment: "Delete action title")
        let deleteAction = UIContextualAction(style: .destructive, title: deleteActionsTitle) { [weak self] _, _, completion in
            self?.viewModel.deleteReminder(with: id)
            self?.viewModel.updateSnapshot(reloading: nil)
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
    
    func suplementaryRegistrationHeader(progressView : ProgressHeaderView,elementKind : String,indexPath : IndexPath) {
        headerView = progressView
    }
}

