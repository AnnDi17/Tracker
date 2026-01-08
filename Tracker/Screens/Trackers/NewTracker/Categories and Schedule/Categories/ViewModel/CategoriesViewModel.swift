//
//  CategoriesViewModel.swift
//  Tracker
//

final class CategoriesViewModel {
    
    private let store = TrackerCategoryStore()
    private(set) var categories: [CategoryViewModel] = []{
        didSet{
            onCategoriesDidChange?(categories)
        }
    }
    
    var onCategoriesDidChange: Binding<[CategoryViewModel]>?
    var onError: Binding<Error>?
    
    init() {
        loadCategoriesFromStore()
    }
    
    func addCategoryToStore(_ name: String){
        do {
            try store.addToStore(name)
            loadCategoriesFromStore()
        }
        catch {
            assertionFailure("CategoriesViewModel.addCategoryToStore(\(name)): Failed to add category - \(error)")
        }
    }
    
    func deleteFromStore(_ category: CategoryViewModel){
        do{
            try store.deleteFromStore(category.name)
            loadCategoriesFromStore()
        }
        catch {
            if let storeError = error as? TrackerCategoryStoreError, storeError == .hasLinkedTrackers {
                onError?(storeError)
            } else {
                assertionFailure("CategoriesViewModel.deleteFromStore: Failed to delete category - \(error)")
            }
        }
    }
    
    func editCategoryInStore(_ category: CategoryViewModel, newName: String){
        do{
            try store.editCategory(withOldTitle: category.name, toNewTitle: newName)
            loadCategoriesFromStore()
        }
        catch {
            assertionFailure("CategoriesViewModel.editCategoryInStore(\(category.name), \(newName)): Failed to edit category - \(error)")
        }
    }
    
    private func loadCategoriesFromStore() {
        do {
            categories = try store.fetchAll().map{
                CategoryViewModel(name: $0)
            }
        }
        catch {
            assertionFailure("CategoriesViewModel.getCategoriesFromStore(): Failed to fetch categories - \(error)")
        }
    }
}

