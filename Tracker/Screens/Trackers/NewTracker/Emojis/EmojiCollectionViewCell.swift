//
//  EmojiCollectionViewCell.swift
//  Tracker
//


import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier: String = "EmojiCollectionViewCell"
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        contentView.addSubviews([emojiLabel])
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            emojiLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(with text: String){
        emojiLabel.text = text
    }
}
