//
//  TrackerRecordStore.swift
//  Tracker
//

import UIKit
import CoreData

final class TrackerRecordStore{
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    func fetchAll() throws -> [TrackerRecord] {
        let request = TrackerRecordCoreData.fetchRequest()
        let data = try context.fetch(request)
        return data.map({self.trackerRecordFromCoreData($0)})
    }
    
    func addToStore(_ trackerRecord: TrackerRecord) throws {
        let newData = TrackerRecordCoreData(context: context)
        newData.trackerId = trackerRecord.id
        newData.date = trackerRecord.date
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@",#keyPath(TrackerCoreData.trackerId),trackerRecord.id as CVarArg)
        request.fetchLimit = 1
        let result = try context.fetch(request)
        if result.isEmpty {
            print("TrackerRecordStore.addToStore: tracker with \(trackerRecord.id) not found") }
        else {
            newData.tracker = result[0]
        }
        try context.save()
    }
    
    func deleteFromStore(trackerId: UUID, date: Date) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@",#keyPath(TrackerRecordCoreData.trackerId),trackerId as CVarArg, #keyPath(TrackerRecordCoreData.date),date as CVarArg)
        request.fetchLimit = 1
        let result = try context.fetch(request)
        if result.isEmpty {
            print("TrackerRecordStore.deleteFromStore: TrackerRecord with \(trackerId) and \(date) not found") }
        else {
            context.delete(result[0])
            try context.save()
        }
    }
    
    private func trackerRecordFromCoreData(_ data: TrackerRecordCoreData) -> TrackerRecord {
        guard let id = data.trackerId else { fatalError("id is nil") }
        guard let date = data.date else { fatalError("date is nil") }
        let trackerRecord = TrackerRecord(id: id, date: date)
        return trackerRecord
    }
    
}
