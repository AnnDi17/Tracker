//
//  MetricViewModel.swift
//  Tracker
//

final class MetricViewModel{
    let name: String
    let value: Int
    
    init(name: String, value: Int) {
        self.name = name
        self.value = value
    }
    
    var valueBinding: Binding<(String, Int)>? {
        didSet {
            valueBinding?((name, value))
        }
    }
}

