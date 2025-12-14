//
//  DaysTableViewCell.swift
//  Tracker
//

import UIKit

final class DaysTableViewCell: UITableViewCell {
    static let reuseIdentifier = "DaysTableViewCell"
    
    var valueDidChange: ((Bool) -> Void)?
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .TrBlackDay
        return label
    }()
    
    private let switchItem: UISwitch = {
        return UISwitch()
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .TrBackgroundDay
        contentView.addSubviews([dayLabel,switchItem])
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(with text: String){
        dayLabel.text = text
        switchItem.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    
    @objc private func switchValueChanged(){
        valueDidChange?(switchItem.isOn)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            switchItem.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switchItem.leadingAnchor.constraint(equalTo: dayLabel.trailingAnchor, constant: 16),
            switchItem.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchItem.widthAnchor.constraint(equalToConstant: 51),
            switchItem.heightAnchor.constraint(equalToConstant: 31)
        ])
    }
}

