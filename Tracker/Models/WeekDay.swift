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
        case .mon: "Пн"
        case .tue: "Вт"
        case .wed: "Ср"
        case .thu: "Чт"
        case .fri: "Пт"
        case .sat: "Сб"
        case .sun: "Вск"
        }
    }
}
