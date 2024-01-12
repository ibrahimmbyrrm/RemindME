//
//  ReminderListViewController+Actions.swift
//  Today
//
//  Created by İbrahim Bayram on 8.01.2024.
//

import UIKit

extension ReminderListViewController {
    
    @objc func listStyleDidChange(_ sender : UISegmentedControl) {
        viewModel.listStyleDidChange(sender.selectedSegmentIndex)
    }
    
    @objc func didPressButton(_ sender: ReminderDoneButton) {
        guard let id = sender.id else { return }
        viewModel.completeReminder(with: id)
    }
    @objc func didPressAddbutton(_ sender : UIBarButtonItem) {
        let reminder = Reminder(title: "", dueDate: Date.now)
        let viewController = ReminderViewController(reminder: reminder) { [weak self] reminder in
            self?.viewModel.addReminder(reminder)
            self?.viewModel.updateSnapshot(reloading: nil)
            self?.dismiss(animated: true)
        }
        viewController.isAddingNewReminder = true
        viewController.setEditing(true, animated: false)
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel, target: self, action: #selector(didCancelAdd(_:)))
        viewController.navigationItem.title = NSLocalizedString(
            "Add Reminder", comment: "Add Reminder view controller title")
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
    @objc func didCancelAdd(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}
