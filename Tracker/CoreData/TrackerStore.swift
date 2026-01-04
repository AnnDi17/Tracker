//
//  TrackerStore.swift
//  Tracker

import UIKit
import CoreData

final class TrackerStore: NSObject{
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    
    weak var delegate: TrackerStoreDelegate?
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
    }
    
    convenience override init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    func getTrackers() -> [TrackerCategory]{
        guard let sections = fetchedResultsController.sections else { return [] }
        var categories: [TrackerCategory] = []
        for сategoryData in sections {
            let title = сategoryData.name
            let trackersData = (сategoryData.objects as? [TrackerCoreData]) ?? []
            let trackers = trackersData.map { trackerFromCoreData($0) }
            categories.append(TrackerCategory(title: title, trackers: trackers))
        }
        return categories
    }
    
    func addToStore(_ tracker: Tracker, categoryName: String) throws{
        let newTracker = TrackerCoreData(context: context)
        newTracker.trackerId = tracker.id
        newTracker.name = tracker.name
        newTracker.color = UIColorMarshalling.hexString(from:tracker.color)
        newTracker.emoji = tracker.emoji
        let data = ScheduleTransformer().transformedValue(tracker.schedule) as? Data
        newTracker.schedule = data
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@",#keyPath(TrackerCategoryCoreData.title), categoryName)
        request.fetchLimit = 1
        let result = try context.fetch(request)
        if result.isEmpty{
            print("TrackerStore.addToStore: category with name \(categoryName) doesn't exist")
        }
        else{
            newTracker.category = result[0]
        }
        try context.save()
    }
    
    private func trackerFromCoreData(_ data: TrackerCoreData) -> Tracker {
        guard let id = data.trackerId else { fatalError("No ID on \(data)") }
        guard let name = data.name else { fatalError("No name on \(data)") }
        guard let colorHex = data.color else { fatalError("No color on \(data)") }
        guard let emoji = data.emoji else { fatalError("No emoji on \(data)") }
        guard let scheduleData = data.schedule else { fatalError("No schedule on \(data)") }
        guard let schedule = ScheduleTransformer().reverseTransformedValue(scheduleData) as? [WeekDay] else { fatalError("Schedule is not in correct format on \(data)") }
        
        let color = UIColorMarshalling.color(from: colorHex)
        
        let tracker = Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
        return tracker
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(self)
    }
}
