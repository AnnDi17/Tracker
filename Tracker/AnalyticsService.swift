//
//  AnalyticsService.swift
//  Tracker
//

import AppMetricaCore

enum analiticEvent: String {
    case open, close, click
}

final class AnalyticsService {
    static let apiKey = "74cb76c0-6bbf-43ff-9ee1-00767aab904a"
    
    func sendEvent(screenName: String, event: analiticEvent, item: String = "") {
        let params : [AnyHashable : Any] = ["screen": screenName, "item": item]
        AppMetrica.reportEvent(name: event.rawValue, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}

