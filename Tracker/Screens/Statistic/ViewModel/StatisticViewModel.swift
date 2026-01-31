//
//  StatisticViewModel.swift
//  Tracker
//
import Foundation

final class StatisticViewModel {
    
    private let statisticStore = StatisticStore()
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    private let calculator = StatisticsCalculator()
    private(set) var statistic: [MetricViewModel] = []{
        didSet{
            onStatisticDidChange?(statistic)
        }
    }
    
    var onStatisticDidChange: Binding<[MetricViewModel]>?
    
    init() {
        loadStatisticFromStore()
        NotificationCenter.default.addObserver(self, selector: #selector(handleDataChange), name: .trackerDidAdd, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDataChange), name: .trackerRecordDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDataChange), name: .trackerDidDelete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDataChange), name: .trackerDidUpdate, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func updateMetricsInStore(new metrics: [MetricViewModel]){
        metrics.forEach {
            statisticStore.updateInStore(new: Metric(name: $0.name, value: $0.value))
        }
        loadStatisticFromStore()
    }
    
    private func loadStatisticFromStore() {
        statistic = trackerStore.hasTrackers() ? statisticStore.fetchAll().map{MetricViewModel(name: $0.name, value: $0.value)} : []
    }
    
    @objc private func handleDataChange(){
        do {
            let categories = trackerStore.getTrackers()
            let completedTrackers = try trackerRecordStore.fetchAll()
            let metrics = calculator.totalStatistic(categories: categories, completedTrackers: completedTrackers).map{
                MetricViewModel(name: $0.name, value: $0.value)
            }
            updateMetricsInStore(new: metrics)
        }
        catch {
            print("StatisticViewModel.handleDataChange: failed to fetch data - \(error)")
        }
    }
}


