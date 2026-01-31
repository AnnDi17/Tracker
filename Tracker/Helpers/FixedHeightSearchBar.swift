//
//  FixedHeightSearchBar.swift
//  Tracker
//

import UIKit

final class FixedHeightSearchBar: UISearchBar {
    var textFieldHeight: CGFloat = 12

    override func layoutSubviews() {
        super.layoutSubviews()

        let tf = self.searchTextField
        var f = tf.frame
        f.size.height = textFieldHeight
        f.origin.y = (bounds.height - textFieldHeight) / 2
        tf.frame = f
    }
}
