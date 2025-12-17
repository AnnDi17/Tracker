//
//  trackersCollectionViewCell.swift
//  Tracker
//

import UIKit

final class TrackersCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier: String = "TrackersCollectionViewCell"
    
    var onButtonTap: (()->Void)?
    
    private var trackerView = UIView()
    private var emojiLabel = UILabel()
    private var nameLabel = UILabel()
    
    private var completedButton = UIButton()
    private var daysLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        trackerView.addSubviews([emojiLabel, nameLabel])
        contentView.addSubviews([trackerView, daysLabel, completedButton])
        
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: emojiLabel.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: -12),
            
            trackerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerView.heightAnchor.constraint(equalToConstant: 90),
            
            completedButton.widthAnchor.constraint(equalToConstant: 34),
            completedButton.heightAnchor.constraint(equalToConstant: 34),
            completedButton.topAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: 12),
            completedButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completedButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysLabel.trailingAnchor.constraint(equalTo: completedButton.leadingAnchor, constant: -8),
            daysLabel.centerYAnchor.constraint(equalTo: completedButton.centerYAnchor)
        ])
        
        trackerView.layer.cornerRadius = 16
        trackerView.layer.masksToBounds = true
        
        emojiLabel.textAlignment = .center
        emojiLabel.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.3)
        emojiLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        emojiLabel.layer.cornerRadius = 12
        emojiLabel.clipsToBounds = true

        nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        nameLabel.textColor = .TrWhiteDay
        
        daysLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        daysLabel.textColor = .TrBlackDay
        
        completedButton.addTarget(self, action: #selector(didTapCompletedButton), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()
        completedButton.layer.cornerRadius = completedButton.bounds.width / 2
        completedButton.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(description: String, emoji: String, color: UIColor, daysCount: Int, isCompleted: Bool){
        nameLabel.text = description
        emojiLabel.text = emoji
        trackerView.backgroundColor = color
        
        completedButton.backgroundColor = isCompleted ? color.withAlphaComponent(0.3) : color
        let image = isCompleted ? UIImage(resource: .checkmarkCustom).withTintColor(.TrWhiteDay) : UIImage(resource: .plusCustom).withTintColor(.TrWhiteDay)
        completedButton.setImage(image, for: .normal)
        
        let days = WordsMaker.standard.days(for: daysCount)
        daysLabel.text = "\(daysCount)" + " " + days
    }
    
    @objc private func didTapCompletedButton(){
        onButtonTap?()
    }
}
