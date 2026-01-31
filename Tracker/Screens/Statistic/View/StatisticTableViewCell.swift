//
//  StatisticTableViewCell.swift
//  Tracker
//

import UIKit
import QuartzCore

final class StatisticTableViewCell: UITableViewCell {
    static let reuseIdentifier = "StatisticTableViewCell"
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .TrBlackDay
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .TrBlackDay
        return label
    }()
    
    private let gradientBorderLayer = CAGradientLayer()
    private let gradientMaskLayer = CAShapeLayer()
    
    var viewModel: MetricViewModel? {
        didSet {
            viewModel?.valueBinding = { [weak self] data in
                self?.nameLabel.text = data.0
                self?.valueLabel.text = String(data.1)
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .TrWhiteDay
        contentView.layer.masksToBounds = false
        
        contentView.addSubviews([valueLabel, nameLabel])
        
        configureGradientBorder()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientBorderLayer.frame = contentView.bounds
        let cornerRadius: CGFloat = 16
        let inset = gradientMaskLayer.lineWidth / 2.0
        let rect = contentView.bounds.insetBy(dx: inset, dy: inset)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        gradientMaskLayer.path = path.cgPath
    }
    
    private func configureGradientBorder() {
        contentView.layer.borderWidth = 0
        gradientBorderLayer.colors = [
            UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1).cgColor,
            UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1).cgColor,
            UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1).cgColor
        ]
        gradientBorderLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientBorderLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientBorderLayer.locations = [0, 0.5, 1]
        gradientBorderLayer.masksToBounds = false

        gradientMaskLayer.fillColor = UIColor.clear.cgColor
        gradientMaskLayer.strokeColor = UIColor.black.cgColor
        gradientMaskLayer.lineWidth = 1

        gradientBorderLayer.mask = gradientMaskLayer
        contentView.layer.addSublayer(gradientBorderLayer)
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            nameLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}

