//
//  Filters.swift
//  Tracker
//

import Foundation

enum Filters: String, CaseIterable {
    case all, today, canceled, notCanceled
    
    static let key = "filters"
    
    var title: String{
        switch self {
        case .all: return NSLocalizedString("all_trackers", comment: "")
        case .today: return NSLocalizedString("today_trackers", comment: "")
        case .canceled: return NSLocalizedString("canceled_trackers", comment: "")
        case .notCanceled: return NSLocalizedString("not_canceled_trackers", comment: "")
        }
    }
    
}
