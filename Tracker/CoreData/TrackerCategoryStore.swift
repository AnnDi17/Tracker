//
//  TrackerCategoryStore.swift
//  Tracker
//

import UIKit
import CoreData

enum TrackerCategoryStoreError: Error {
    case hasLinkedTrackers
}

extension Notification.Name {
    static let trackerCategoryDidChange = Notification.Name("trackerCategoryDidChange")
}

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
    
    func fetchAll() throws -> [String] {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        let data = try context.fetch(request)
        return data.map{$0.title ?? ""}
    }
    
    func addToStore(_ category: String) throws{
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = category
        try context.save()
    }
    
    func deleteFromStore(_ title: String) throws{
        if try hasTrackers(withTitle: title) {
            throw TrackerCategoryStoreError.hasLinkedTrackers
        }
        guard let result = try getCategory(withTitle: title) else {
            print("TrackerCategoryStore.deleteFromStore: no category with that title")
            return
        }
        context.delete(result)
        try context.save()
    }
    
    func editCategory(withOldTitle oldTitle: String, toNewTitle newTitle: String) throws {
        guard let result = try getCategory(withTitle: oldTitle) else {
            print("TrackerCategoryStore.editCategory: no category with that title")
            return
        }
        result.title = newTitle
        try context.save()
        NotificationCenter.default.post(name: .trackerCategoryDidChange, object: nil)
    }
    
    func isExistingCategory(withTitle title: String) throws -> Bool {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), title)
        request.fetchLimit = 1
        let count = try context.count(for: request)
        return count > 0
    }
    
    private func hasTrackers(withTitle title: String) throws -> Bool {
        guard let category = try getCategory(withTitle: title) else {
            return false
        }
        let count = (category.value(forKey: "tracker") as? NSSet)?.count ?? 0
        return count > 0
    }
    
    private func getCategory(withTitle title: String) throws -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@",#keyPath(TrackerCategoryCoreData.title),title)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}

