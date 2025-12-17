//
//  NewHabitViewController.swift
//  Tracker
//

import UIKit

final class NewHabitViewController: UIViewController {
    
    var createHabit: ((Tracker, String) -> Void)?
    
    private let settingsTableView = UITableView()
    private let nameTextField = PaddedTextField()
    private let errorLabel = UILabel()
    private var errorHeightConstraint: NSLayoutConstraint!
    
    private var days: [WeekDay] = []
    private var category: String = "Важное"
    private var name: String = ""
    private var emoji: String = "🌟"
    private var trackerColor: UIColor = .TrBlue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .TrWhiteDay
        
        let titleLabel = getTitleLabel()
        
        let scrollView = UIScrollView()
        let contentView = UIView()
        scrollView.addSubviews([contentView])
        setupNameTextField()
        setupErrorLabel()
        setupSettingsTableView()
        contentView.addSubviews([nameTextField, errorLabel, settingsTableView])
        
        let buttonsStackView = getButtonsStackView()
        
        view.addSubviews([titleLabel, scrollView, buttonsStackView])
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -14),
            
            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            errorLabel.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            
            settingsTableView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            settingsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            settingsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            settingsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            settingsTableView.heightAnchor.constraint(equalToConstant: 150),
            
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func getTitleLabel() -> UILabel{
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .TrBlackDay
        return label
    }
    
    private func setupNameTextField(){
        nameTextField.padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        nameTextField.placeholder = "Введите название трекера"
        nameTextField.layer.cornerRadius = 16
        nameTextField.backgroundColor = .TrBackgroundDay
        
        nameTextField.returnKeyType = .done
        nameTextField.delegate = self
    }
    
    private func setupErrorLabel(){
        errorLabel.text = "Ограничение 38 символов"
        errorLabel.font = UIFont.systemFont(ofSize: 17)
        errorLabel.textColor = .TrRed
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true
        errorHeightConstraint = errorLabel.heightAnchor.constraint(equalToConstant: 0)
        errorHeightConstraint.isActive = true
    }
    
    private func setupSettingsTableView(){
        settingsTableView.dataSource = self
        settingsTableView.delegate = self
        settingsTableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.reuseIdentifier)
        settingsTableView.layer.cornerRadius = 16
        settingsTableView.layer.masksToBounds = true
        settingsTableView.tableFooterView = UIView(frame: .init(x: 0, y: 0, width: 0, height: 0.01))
        settingsTableView.isScrollEnabled = false
    }
    
    private func getButtonsStackView() -> UIStackView{
        let createButton = getCreateButton()
        let cancelButton = getCancelButton()
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func getCreateButton() -> UIButton{
        let button = UIButton()
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(UIColor.TrWhiteDay, for: .normal)
        button.backgroundColor = .TrGray
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }
    
    private func getCancelButton() -> UIButton{
        let button = UIButton()
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor.TrRed, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.TrRed.cgColor
        return button
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func cancelButtonTapped(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func createButtonTapped(){
        let name = nameTextField.text ?? ""
        let newTracker = Tracker(
            id: UUID(),
            name: name,
            color: trackerColor,
            emoji: emoji,
            schedule: days
        )
        createHabit?(newTracker, category)
        dismiss(animated: true, completion: nil)
    }
    
}

extension NewHabitViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = settingsTableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.reuseIdentifier, for: indexPath) as? SettingsTableViewCell else {
            print("Error dequeuing cell")
            return UITableViewCell()
        }
        
        var daysString = ""
        let daysCount = days.count
        if daysCount > 0 && daysCount != 7 {
            for dayNumber in 0..<daysCount-1 {
                daysString.append("\((days[dayNumber].day)), ")
            }
            daysString.append(days[daysCount-1].day)
        }
        
        if daysCount == 7 {
            daysString = "Каждый день"
        }
        
        let description = indexPath.row == 0 ? category : daysString
        
        cell.config(with: indexPath.row == 0 ? "Категория" : "Расписание",description)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let vc = ScheduleViewController()
            vc.daysDidSelect = {[weak self] days in
                self?.days = days
                self?.settingsTableView.reloadRows(at: [indexPath], with: .automatic)
            }
            present(vc, animated: true)
        }
    }
}

extension NewHabitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        
        let currentText = textField.text ?? ""
        guard let textRange = Range(range, in: currentText) else { return false }
        
        let newText = currentText.replacingCharacters(in: textRange, with: string)
        
        if newText.count > 38 {
            errorLabel.isHidden = false
            errorHeightConstraint.isActive = false
            return false
        }
        
        errorLabel.isHidden = true
        errorHeightConstraint.isActive = true
        return true
    }
}
