//
//  NewHabitViewController.swift
//  Tracker
//

#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview {
    NewHabitViewController()
}
#endif

final class NewHabitViewController: UIViewController {
    
    var createHabit: ((Tracker, String) -> Void)?
    
    private let settingsTableView = UITableView()
    private let nameTextField = PaddedTextField()
    private let errorLabel = UILabel()
    private var errorHeightConstraint: NSLayoutConstraint!
    private let emojiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let colorsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private var days: [WeekDay] = []
    private var category: String = "Важное"
    private var name: String = ""
    private var emojis: [String] = [
        "😀", "😇", "😂", "😍", "🥳", "😎", "😴", "🤔", "🤩",
        "🚀", "🎉", "🔥", "🌟", "⚡️", "🍀", "🍎", "🍩",
        "🍕", "🥑", "🌳", "🌞", "🌙", "🐶", "🐱", "🦄", "🐢",
        "🎨", "🎸", "🎧", "🏆", "📚", "💡", "❤️", "🧠"
    ]
    private var colors: [UIColor] = [
        UIColor(red: 255/255, green: 69/255,  blue: 58/255,  alpha: 1),
        UIColor(red: 255/255, green: 159/255, blue: 10/255,  alpha: 1),
        UIColor(red: 255/255, green: 214/255, blue: 10/255,  alpha: 1),
        UIColor(red: 52/255,  green: 199/255, blue: 89/255,  alpha: 1),
        UIColor(red: 48/255,  green: 176/255, blue: 199/255, alpha: 1),
        UIColor(red: 50/255,  green: 173/255, blue: 230/255, alpha: 1),
        UIColor(red: 0/255,   green: 122/255, blue: 255/255, alpha: 1),
        UIColor(red: 88/255,  green: 86/255,  blue: 214/255, alpha: 1),
        UIColor(red: 175/255, green: 82/255,  blue: 222/255, alpha: 1),
        UIColor(red: 255/255, green: 55/255,  blue: 95/255,  alpha: 1),
        UIColor(red: 255/255, green: 105/255, blue: 180/255, alpha: 1),
        UIColor(red: 255/255, green: 204/255, blue: 0/255,   alpha: 1),
        UIColor(red: 100/255, green: 210/255, blue: 255/255, alpha: 1),
        UIColor(red: 64/255,  green: 224/255, blue: 208/255, alpha: 1),
        UIColor(red: 60/255,  green: 179/255, blue: 113/255, alpha: 1),
        UIColor(red: 154/255, green: 205/255, blue: 50/255,  alpha: 1),
        UIColor(red: 210/255, green: 105/255, blue: 30/255,  alpha: 1),
        UIColor(red: 112/255, green: 128/255, blue: 144/255, alpha: 1)
    ]
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
        setupEmojiCollectionView()
        setupColorCollectionView()
        
        contentView.addSubviews([nameTextField, errorLabel, settingsTableView, emojiCollectionView, colorsCollectionView])
        
        let buttonsStackView = getButtonsStackView()
        
        view.addSubviews([titleLabel, scrollView, buttonsStackView])
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        let heightEmojiCollectionView = getHeightForCollectionView(numberOfItems: emojis.count)
        let heightColorsCollectionView = getHeightForCollectionView(numberOfItems: colors.count)
        
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
            settingsTableView.heightAnchor.constraint(equalToConstant: 150),
            
            emojiCollectionView.topAnchor.constraint(equalTo: settingsTableView.bottomAnchor, constant: 32),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: heightEmojiCollectionView),
            
            colorsCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            colorsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            colorsCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            colorsCollectionView.heightAnchor.constraint(equalToConstant: heightColorsCollectionView),
            
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
    
    private func setupEmojiCollectionView(){
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        emojiCollectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier)
        emojiCollectionView.register(EmojiSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmojiSectionHeaderView.reuseIdentifier)
    }
    
    private func setupColorCollectionView(){
        colorsCollectionView.delegate = self
        colorsCollectionView.dataSource = self
        colorsCollectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifier)
        colorsCollectionView.register(ColorSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ColorSectionHeaderView.reuseIdentifier)
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
            emoji: emojis[0],
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

extension NewHabitViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case emojiCollectionView:
            return emojis.count
        case colorsCollectionView:
            return colors.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView{
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        switch collectionView {
        case emojiCollectionView:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: EmojiSectionHeaderView.reuseIdentifier, for: indexPath) as? EmojiSectionHeaderView else {
                print("collectionView: could not create Header View")
                return UICollectionReusableView()
            }
            headerView.config(with: "Emoji")
            return headerView
        case colorsCollectionView:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ColorSectionHeaderView.reuseIdentifier, for: indexPath) as? ColorSectionHeaderView else {
                print("collectionView: could not create Header View")
                return UICollectionReusableView()
            }
            headerView.config(with: "Цвет")
            return headerView
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case emojiCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier, for: indexPath) as? EmojiCollectionViewCell else {
                print("collectionView: could not create cell")
                return UICollectionViewCell()
            }
            cell.config(with: emojis[indexPath.row])
            return cell
        case colorsCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier, for: indexPath) as? ColorCollectionViewCell else {
                print("collectionView: could not create cell")
                return UICollectionViewCell()
            }
            cell.config(with: colors[indexPath.row])
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

extension NewHabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0)
        return insets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        let height = getHeightForHeader()
        return CGSize(width: collectionView.bounds.width, height: height)
    }
    
    private func getNumberOfLines(leftBorder: CGFloat, rightBorder: CGFloat, numberOfItems: Int, itemWidth: CGFloat) -> Int{
        let totalWidth = view.bounds.width - leftBorder - rightBorder
        let itemsInLine = Int(totalWidth/itemWidth)
        let lines = (numberOfItems + itemsInLine - 1) / itemsInLine
        return lines
    }
    
    private func getHeightForCollectionView(numberOfItems: Int) -> CGFloat{
        let headerHeight = getHeightForHeader()
        let totalLines = getNumberOfLines(leftBorder: 18, rightBorder: 18, numberOfItems: numberOfItems, itemWidth: 52)
        let totalHeight = CGFloat(52*totalLines) + headerHeight + 24 + 24
        return totalHeight
    }
    
    private func getHeightForHeader() -> CGFloat{
        let top: CGFloat = 0
        let bottom: CGFloat = 0
        let lineHeight = UIFont.systemFont(ofSize: 19, weight: .bold).lineHeight
        let headerHeight = top + lineHeight + bottom
        return headerHeight
    }
}

