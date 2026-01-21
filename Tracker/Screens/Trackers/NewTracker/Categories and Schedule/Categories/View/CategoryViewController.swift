//
//  CategoryViewController.swift
//  Tracker
//

import UIKit

final class CategoryViewController: UIViewController {
    
    private let titleLabel = UILabel()
    private let nameTextField = PaddedTextField()
    private let okButton = UIButton()
    
    private let titleScreen: String
    private var textForTextField: String = ""
    private let onButtonTapped: (String) -> Void
    
    init(title: String, action: @escaping (String) -> Void){
        self.titleScreen = title
        self.onButtonTapped = action
        super.init(nibName: nil, bundle: nil)
    }
    
    init(title: String, textForTextField: String, action: @escaping (String) -> Void){
        self.titleScreen = title
        self.onButtonTapped = action
        self.textForTextField = textForTextField
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .TrWhiteDay
        
        setupTitleLabel()
        setupNameTextField()
        setupCreateButton()
        
        view.addSubviews([titleLabel,nameTextField, okButton])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            okButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            okButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            okButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -16),
            okButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func setupTitleLabel(){
        titleLabel.text = titleScreen
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .TrBlackDay
    }
    
    private func setupNameTextField(){
        nameTextField.text = textForTextField
        nameTextField.padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        nameTextField.placeholder = NSLocalizedString("enter_category_name", comment: "text for textField placeholder")//"Введите название категории"
        nameTextField.layer.cornerRadius = 16
        nameTextField.backgroundColor = .TrBackgroundDay
        nameTextField.returnKeyType = .done
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupCreateButton(){
        okButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        okButton.setTitle(NSLocalizedString("done", comment: "text for ok button"), for: .normal)
        okButton.setTitleColor(UIColor.TrWhiteDay, for: .normal)
        okButton.backgroundColor = .TrGray
        okButton.layer.cornerRadius = 16
        okButton.layer.masksToBounds = true
        okButton.isEnabled = false
    }
    
    @objc private func textFieldDidChange(){
        let currentText = nameTextField.text ?? ""
        if currentText.count > 0 {
            okButton.backgroundColor = .TrBlackDay
            okButton.isEnabled = true
        } else {
            okButton.backgroundColor = .TrGray
            okButton.isEnabled = false
        }
        
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func createButtonTapped(){
        let name = nameTextField.text ?? ""
        onButtonTapped(name)
        dismiss(animated: true, completion: nil)
    }
    
}

extension CategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
