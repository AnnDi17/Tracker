//
//  FiltersTableViewCell.swift
//  Tracker
//

import UIKit

final class FiltersTableViewCell: UITableViewCell {
    static let reuseIdentifier = "FiltersTableViewCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .TrBlackDay
        return label
    }()
    
    private let checkItem: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.image = UIImage(systemName: "checkmark")
        view.tintColor = .TrBlue
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .TrBackgroundDay
        contentView.addSubviews([nameLabel,checkItem])
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    func config(isChecked: Bool, title: String){
        checkItem.isHidden = !isChecked
        nameLabel.text = title
    }
    
    func updateStatus(isChecked: Bool) {
        checkItem.isHidden = !isChecked
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            checkItem.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkItem.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            checkItem.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkItem.widthAnchor.constraint(equalToConstant: 24),
            checkItem.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

}

