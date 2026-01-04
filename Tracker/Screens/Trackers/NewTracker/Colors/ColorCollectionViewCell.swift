//
//  ColorCollectionViewCell.swift
//  Tracker
//


import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier: String = "ColorCollectionViewCell"
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        contentView.addSubviews([colorView])
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(with color: UIColor){
        colorView.backgroundColor = color
        contentView.layer.borderWidth = 3
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        contentView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func didSelect(){
        let color = colorView.backgroundColor ?? UIColor.clear
        contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
    }
    
    func didDeselect(){
        contentView.layer.borderColor = UIColor.clear.cgColor
    }
}
