//
//  ScheduleTransformer.swift
//  Tracker
//


import UIKit

final class ScheduleTransformer {
    
    static func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [WeekDay] else { return nil }
        return try? JSONEncoder().encode(days)
    }
    
    static func reverseTransformedValue(_ value: Any?) -> Any? {
        if let data = value as? Data {
            return try? JSONDecoder().decode([WeekDay].self, from: data)
        }
        if let data = value as? NSData {
            return try? JSONDecoder().decode([WeekDay].self, from: data as Data)
        }
        return nil
    }
    
}
