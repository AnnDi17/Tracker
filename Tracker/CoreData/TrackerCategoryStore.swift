//
//  TrackerCategoryStore.swift
//  Tracker
//

import UIKit
import CoreData

final class TrackerCategoryStore{
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            fatalError("TrackerCategoryStore: error getting AppDelegate")
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    func addToStore(_ category: String) throws{
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = category
        try context.save()
    }
    
    func isExistingCategory(withTitle title: String) throws -> Bool {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), title)
        request.fetchLimit = 1
        let count = try context.count(for: request)
        return count > 0
    }
}

