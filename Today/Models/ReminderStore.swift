//
//  ReminderStore.swift
//  Today
//
//  Created by İbrahim Bayram on 9.01.2024.
//

import EventKit

final class ReminderStore {
    static let shared = ReminderStore()
    
    
    private let ekStore = EKEventStore()
    
    
    var isAvailable: Bool {
        EKEventStore.authorizationStatus(for: .reminder) == .fullAccess || EKEventStore.authorizationStatus(for: .reminder) == .writeOnly
    }
    
    func requestAccess() async throws {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        switch status {
        case .denied:
            throw TodayError.accessDenied
        case .restricted:
            throw TodayError.accessRestricted
        case .notDetermined:
            let accessGranted = try await ekStore.requestFullAccessToReminders()
            guard accessGranted else {
                throw TodayError.accessDenied
            }
        case .fullAccess,.writeOnly: return
        @unknown default:
            throw TodayError.unknown
        }
    }
    
    func remove(with id : Reminder.ID) throws {
        guard isAvailable else {
            throw TodayError.accessDenied
        }
        let ekReminder = try read(with: id)
        try ekStore.remove(ekReminder, commit: true)
    }
    
    @discardableResult
    func save(_ reminder: Reminder) throws -> Reminder.ID {
        guard isAvailable else {
            throw TodayError.accessDenied
        }
        let ekReminder: EKReminder
        do {
            ekReminder = try read(with: reminder.id)
        } catch {
            ekReminder = EKReminder(eventStore: ekStore)
        }
        ekReminder.update(using: reminder, in: ekStore)
        try ekStore.save(ekReminder, commit: true)
        return ekReminder.calendarItemIdentifier
    }
    
    func readAll() async throws -> [Reminder] {
        guard isAvailable else {
            throw TodayError.accessDenied
        }
        let predicate = ekStore.predicateForReminders(in: nil)
        let ekReminders = try await ekStore.reminders(matching: predicate)
        let reminders: [Reminder] = try ekReminders.compactMap { ekReminder in
            do {
                return try Reminder(with: ekReminder)
            } catch TodayError.reminderHasNoDueDate {
                return nil
            }
        }
        return reminders
    }
    
    private func read(with id : Reminder.ID) throws -> EKReminder {
        guard let ekReminder = ekStore.calendarItem(withIdentifier: id) as? EKReminder else {
            throw TodayError.failedRedingCalentarItem
        }
        return ekReminder
    }
}
