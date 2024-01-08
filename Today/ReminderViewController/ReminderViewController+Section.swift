//
//  ReminderViewController+Section.swift
//  Today
//
//  Created by İbrahim Bayram on 8.01.2024.
//

import UIKit

extension ReminderViewController {
    enum Section : Int,Hashable {
        case view
        case title
        case date
        case notes
        
        var name : String {
            switch self {
            case .view : return ""
            case .title: return NSLocalizedString("Title", comment: "Title section comment")
            case .date: return NSLocalizedString("Date", comment: "Date section comment")
            case .notes: return NSLocalizedString("Notes", comment: "Notes section comment")
            }
        }
    }
}
