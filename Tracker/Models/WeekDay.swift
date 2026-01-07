//
//  WeekDay.swift
//  Tracker
//

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
        case .mon: return "Пн"
        case .tue: return "Вт"
        case .wed: return "Ср"
        case .thu: return "Чт"
        case .fri: return "Пт"
        case .sat: return "Сб"
        case .sun: return "Вск"
        }
    }
}
