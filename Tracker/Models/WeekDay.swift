//
//  WeekDay.swift
//  Tracker
//

import Foundation

enum WeekDay: Int, Codable {
    case mon = 1,
         tue = 2,
         wed = 3,
         thu = 4,
         fri = 5,
         sat = 6,
         sun = 7
    
    var day: String {
        switch self {
        case .mon: NSLocalizedString("weekday_mon", comment: "Short name for Monday")
        case .tue: NSLocalizedString("weekday_tue", comment: "Short name for Tuesday")
        case .wed: NSLocalizedString("weekday_wed", comment: "Short name for Wednesday")
        case .thu: NSLocalizedString("weekday_thu", comment: "Short name for Thursday")
        case .fri: NSLocalizedString("weekday_fri", comment: "Short name for Friday")
        case .sat: NSLocalizedString("weekday_sat", comment: "Short name for Saturday")
        case .sun: NSLocalizedString("weekday_sun", comment: "Short name for Sunday")
        }
    }
}
