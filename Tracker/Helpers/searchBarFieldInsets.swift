//
//  Untitled.swift
//  Tracker
//
import UIKit

extension UISearchBar{
    func searchBarFieldInsets() -> UIEdgeInsets {
        let searchTextField = self.searchTextField
        let rect = searchTextField.convert(searchTextField.bounds, to: self)
        
        return UIEdgeInsets(
            top: rect.minY,
            left: rect.minX,
            bottom: self.bounds.maxY - rect.maxY,
            right: self.bounds.maxX - rect.maxX
        )
    }
}
