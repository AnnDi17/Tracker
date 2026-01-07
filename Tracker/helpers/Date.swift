//
//  Date.swift
//  Tracker
//
import UIKit

extension Date{
    var normDate: Date{
        Calendar.current.startOfDay(for: self)
    }
}
