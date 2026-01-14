//
//  EmojiSectionHeaderView.swift
//  Tracker
//


import UIKit

final class EmojiSectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier: String = "EmojiSectionHeaderView"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = .TrBlackDay
        return label
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        addSubviews([titleLabel])
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    func config(with text: String){
        titleLabel.text = text
    }
}
