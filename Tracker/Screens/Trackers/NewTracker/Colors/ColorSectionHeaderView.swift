//
//  ColorSectionHeaderView.swift
//  Tracker
//


import UIKit

final class ColorSectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier: String = "ColorSectionHeaderView"
    
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(with text: String){
        titleLabel.text = text
    }
}
