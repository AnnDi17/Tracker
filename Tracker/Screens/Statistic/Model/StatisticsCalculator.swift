//
//  StatisticsCalculator.swift
//  Tracker
//

final class StatisticsCalculator{
    func totalStatistic(categories: [TrackerCategory], completedTrackers: [TrackerRecord]) -> [Metric]{
        return [
            Metric(
                name: MetricTitles.completedTrackersCount,
                value: calculateCompletedTrackersCount(completedTrackers)
            )
        ]
    }
    
    private func calculateCompletedTrackersCount(_ completedTrackers: [TrackerRecord]) -> Int{
        completedTrackers.count
    }
}

