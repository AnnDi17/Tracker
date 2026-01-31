//
//  DeleteItemSheetViewController.swift
//  Tracker
//

import UIKit

final class DeleteItemSheetViewController: UIViewController {
    
    private let sheetView = UIView()
    private let messageLabel = UILabel()
    private let deleteButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let separator = UIView()
    private let confirmLabelText: String
    
    var onDelete: (() -> Void)?
    
    init(confirmLabelText: String, onDelete: (() -> Void)?) {
        self.confirmLabelText = confirmLabelText
        self.onDelete = onDelete
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupSheet()
        setupLayout()
    }
    
    private func setupBackground() {
        view.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        let bgTap = UITapGestureRecognizer(target: self, action: #selector(cancelTapped))
        view.addGestureRecognizer(bgTap)
    }
    
    private func setupSheet() {
        sheetView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 0.7)
        sheetView.layer.cornerRadius = 13
        sheetView.layer.masksToBounds = true
        
        messageLabel.text = confirmLabelText
        messageLabel.font = .systemFont(ofSize: 13, weight: .regular)
        messageLabel.textColor = UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.6)
        messageLabel.textAlignment = .center
        
        deleteButton.setTitle(NSLocalizedString("delete", comment: "text for delete button"), for: .normal)
        deleteButton.setTitleColor(.TrSystemRed, for: .normal)
        deleteButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        deleteButton.backgroundColor = .clear
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
        separator.backgroundColor = .TrSeparatorColor
        deleteButton.addSubviews([separator])
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: deleteButton.topAnchor),
            separator.leadingAnchor.constraint(equalTo: deleteButton.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: deleteButton.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        
        cancelButton.setTitle(NSLocalizedString("cancel", comment: "text for cancel button"), for: .normal)
        cancelButton.setTitleColor(.TrSystemBlue, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        cancelButton.backgroundColor = .TrWhiteDay
        cancelButton.layer.cornerRadius = 13
        cancelButton.layer.masksToBounds = true
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        sheetView.addSubviews([messageLabel, deleteButton])
        view.addSubviews([sheetView, cancelButton])
    }
    
    private func setupLayout() {
        let padding: CGFloat = 8
        
        NSLayoutConstraint.activate([
            sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            sheetView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -padding),
            
            messageLabel.topAnchor.constraint(equalTo: sheetView.topAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor),
            messageLabel.heightAnchor.constraint(equalToConstant: 42),
            
            deleteButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor),
            deleteButton.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor),
            deleteButton.heightAnchor.constraint(equalToConstant: 61),
            deleteButton.bottomAnchor.constraint(equalTo: sheetView.bottomAnchor, constant: -8),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            cancelButton.heightAnchor.constraint(equalToConstant: 61),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding)
        ])
    }
    
    @objc private func deleteTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onDelete?()
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}
