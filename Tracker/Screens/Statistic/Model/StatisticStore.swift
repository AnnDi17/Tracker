//
//  StatisticStore.swift
//  Tracker
//

import Foundation

final class StatisticStore{
    func fetchAll() -> [Metric] {
        [
            Metric(
                name: MetricTitles.completedTrackersCount,
                value: UserDefaults.standard.integer(forKey: MetricTitles.completedTrackersCount)
            )
        ]
    }
    
    func addToStore(_ metrics: [Metric]) {
        metrics.forEach {
            UserDefaults.standard.set($0.value, forKey: "\($0.name)")
        }
    }
    
    func updateInStore(new metric: Metric) {
        UserDefaults.standard.set(metric.value, forKey: "\(metric.name)")
    }
}
