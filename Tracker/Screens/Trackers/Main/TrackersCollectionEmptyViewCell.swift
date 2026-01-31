//
//  TrackersCollectionEmptyViewCell.swift
//  Tracker
//

import UIKit

final class TrackersCollectionEmptyViewCell: UICollectionViewCell {
    static let reuseIdentifier: String = "TrackersCollectionEmptyViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
}
