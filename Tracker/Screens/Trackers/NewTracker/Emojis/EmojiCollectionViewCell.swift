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
    
    override var isSelected: Bool{
        didSet{
            if isSelected {
                didSelect()
            } else {
                didDeselect()
            }
        }
    }
    
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
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    func config(with text: String){
        emojiLabel.layer.cornerRadius = 16
        emojiLabel.clipsToBounds = true
        emojiLabel.backgroundColor = .clear
        emojiLabel.text = text
    }
    
    private func didSelect(){
        emojiLabel.backgroundColor = .TrLightGray
    }
    
    private func didDeselect(){
        emojiLabel.backgroundColor = .clear
    }
}
