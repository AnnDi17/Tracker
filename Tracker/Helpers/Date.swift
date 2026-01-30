//
//  Date.swift
//  Tracker
//
import Foundation

extension Date{
    var normDate: Date{
        Calendar.current.startOfDay(for: self)
    }
    
    func weekDay() -> WeekDay? {
            let number = Calendar.current.component(.weekday, from: self)
            let corrected = number == 1 ? 7 : number - 1
            return WeekDay(rawValue: corrected)
        }
}
