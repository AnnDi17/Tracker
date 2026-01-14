//
//  CategoryViewModel.swift
//  Tracker
//

final class CategoryViewModel{
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    var nameBinding: Binding<String>? {
        didSet {
            nameBinding?(name)
        }
    }
}

