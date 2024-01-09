//
//  TodayError.swift
//  Today
//
//  Created by İbrahim Bayram on 9.01.2024.
//

import Foundation

enum TodayError : LocalizedError {
    case failedReadingReminders
    case reminderHasNoDueDate
    case accessDenied
    case failedRedingCalentarItem
    case unknown
    case accessRestricted
    
    var errorDescription: String? {
        switch self {
        case .failedRedingCalentarItem: return NSLocalizedString("Failed to read a calendar item", comment: "failed reading calendar item error description")
        case .failedReadingReminders: return NSLocalizedString("Failed to read reminders.", comment: "failed reading reminders error description")
        case .reminderHasNoDueDate: return NSLocalizedString("The reminder has no due date.", comment: "reminder has no due date error description")
        case .accessDenied: return NSLocalizedString("The app doesn't have permission to read reminders.", comment: "access denied error description")
        case .accessRestricted: return NSLocalizedString("The devise doesn't allow access to reminders.", comment: "access restricted error description")
        case .unknown : return NSLocalizedString("An unknown error occured.", comment: "unknown error description")
        }
    }
}
