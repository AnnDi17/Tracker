//
//  NewHabitViewController.swift
//  Tracker
//
#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview {
    HabitViewController(isNewHabitMode: false)
}
#endif

import UIKit

final class HabitViewController: UIViewController {
    
    var saveHabit: ((Tracker, String) -> Void)?
    
    private let isNewHabitMode: Bool
    
    private let titleForDays = UILabel()
    private let settingsTableView = UITableView()
    private let nameTextField = PaddedTextField()
    private let errorLabel = UILabel()
    private var errorHeightConstraint: NSLayoutConstraint?
    private let emojiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let colorsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private var trackerDays: [WeekDay]
    private var trackerCategory: String
    private var trackerEmoji: String
    private var trackerColor: UIColor
    private var trackerId: UUID
    
    private let emojis: [String] = [
        "😀", "😇", "😂", "😍", "🥳", "😎", "😴", "🤔", "🤩",
        "🚀", "🎉", "🔥", "🌟", "⚡️", "🍀", "🍎", "🍩",
        "🍕", "🥑", "🌳", "🌞", "🌙", "🐶", "🐱", "🦄", "🐢",
        "🎨", "🎸", "🎧", "🏆", "📚", "💡", "❤️", "🧠"
    ]
    private let colors: [UIColor] = [
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
    
    init(isNewHabitMode: Bool, tracker: Tracker? = nil, category: String = ""){
        self.isNewHabitMode = isNewHabitMode
        
        nameTextField.text = tracker?.name
        trackerDays = tracker?.schedule ?? []
        trackerCategory = category
        trackerEmoji = tracker?.emoji ?? ""
        trackerColor = tracker?.color ?? .TrBlue
        trackerId = tracker?.id ?? UUID()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .TrWhiteDay
        
        let titleLabel = getTitleLabel()
        setupTitleForDays()
        
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
        
        view.addSubviews([titleLabel, titleForDays, scrollView, buttonsStackView])
        
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
            
            titleForDays.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            titleForDays.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: titleForDays.bottomAnchor, constant: 14),
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isNewHabitMode {
            guard let rowEmoji = emojis.firstIndex(of: trackerEmoji) else { return }
            let indexPath = IndexPath(row: rowEmoji, section: 0)
            emojiCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            guard let rowColors = colors.firstIndex(of: trackerColor) else { return }
            let indexPathColor = IndexPath(row: rowColors, section: 0)
            colorsCollectionView.selectItem(at: indexPathColor, animated: false, scrollPosition: [])
        }
    }
    
    private func getTitleLabel() -> UILabel{
        let label = UILabel()
        label.text = isNewHabitMode ? NSLocalizedString("new_habit_title", comment: "text displayed in the title label of the habit view controller") : NSLocalizedString("edit_habit_title", comment: "text displayed in the title label of the habit view controller")
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .TrBlackDay
        return label
    }
    
    private func setupTitleForDays(){
        titleForDays.text = isNewHabitMode ? "" : "8 дней"
        titleForDays.font = .systemFont(ofSize: 32, weight: .bold)
        titleForDays.textColor = .TrBlackDay
    }
    
    private func setupNameTextField(){
        nameTextField.padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        nameTextField.placeholder = NSLocalizedString("enter_tracker_name", comment: "text displayed in the name text field placeholder")//"Введите название трекера"
        nameTextField.layer.cornerRadius = 16
        nameTextField.backgroundColor = .TrBackgroundDay
        
        nameTextField.returnKeyType = .done
        nameTextField.delegate = self
    }
    
    private func setupErrorLabel(){
        errorLabel.text = NSLocalizedString("limit_38_char", comment: "text displayed in the error label")//"Ограничение 38 символов"
        errorLabel.font = UIFont.systemFont(ofSize: 17)
        errorLabel.textColor = .TrRed
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true
        errorHeightConstraint? = errorLabel.heightAnchor.constraint(equalToConstant: 0)
        errorHeightConstraint?.isActive = true
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
        emojiCollectionView.allowsSelection = true
        emojiCollectionView.allowsMultipleSelection = false
        emojiCollectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier)
        emojiCollectionView.register(EmojiSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmojiSectionHeaderView.reuseIdentifier)
    }
    
    private func setupColorCollectionView(){
        colorsCollectionView.delegate = self
        colorsCollectionView.dataSource = self
        colorsCollectionView.allowsSelection = true
        colorsCollectionView.allowsMultipleSelection = false
        colorsCollectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifier)
        colorsCollectionView.register(ColorSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ColorSectionHeaderView.reuseIdentifier)
    }
    
    private func getButtonsStackView() -> UIStackView{
        let createButton = isNewHabitMode ? getCreateButton() : getSaveButton()
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
        button.setTitle(NSLocalizedString("create", comment: "text for create button"), for: .normal)
        button.setTitleColor(UIColor.TrWhiteDay, for: .normal)
        button.backgroundColor = .TrGray
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }
    
    private func getSaveButton() -> UIButton{
        let button = UIButton()
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.setTitle(NSLocalizedString("save", comment: "text for save button"), for: .normal)
        button.setTitleColor(UIColor.TrWhiteDay, for: .normal)
        button.backgroundColor = .TrBlackDay
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }
    
    private func getCancelButton() -> UIButton{
        let button = UIButton()
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.setTitle(NSLocalizedString("cancel", comment: "text for cancel button"), for: .normal)
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
        let days = trackerDays.isEmpty ? [.mon,.tue,.wed,.thu,.fri,.sat,.sun] : trackerDays
        let newTracker = Tracker(
            id: trackerId,
            name: name,
            color: trackerColor,
            emoji: trackerEmoji,
            schedule: days
        )
        saveHabit?(newTracker, trackerCategory)
        dismiss(animated: true, completion: nil)
    }
    
}

extension HabitViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.reuseIdentifier, for: indexPath) as? SettingsTableViewCell else {
            print("NewHabitViewController.tableView: Error dequeuing cell")
            return UITableViewCell()
        }
        
        var daysString = ""
        let daysCount = trackerDays.count
        if daysCount > 0 && daysCount != 7 {
            for dayNumber in 0..<daysCount-1 {
                daysString.append("\((trackerDays[dayNumber].day)), ")
            }
            daysString.append(trackerDays[daysCount-1].day)
        }
        
        if daysCount == 7 {
            daysString = NSLocalizedString("every_day", comment: "text for schedule")//"Каждый день"
        }
        
        let description = indexPath.row == 0 ? trackerCategory : daysString
        
        cell.config(with: indexPath.row == 0 ? NSLocalizedString("category", comment: "") : NSLocalizedString("schedule", comment: ""),description)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let vc = CategoriesViewController()
            vc.selectedCategory = trackerCategory
            vc.categoryDidSelect = {[weak self] category in
                self?.trackerCategory = category
                self?.settingsTableView.reloadRows(at: [indexPath], with: .automatic)
            }
            present(vc, animated: true)
        }
        
        if indexPath.row == 1 {
            let vc = ScheduleViewController()
            vc.daysDidSelect = {[weak self] days in
                self?.trackerDays = days
                self?.settingsTableView.reloadRows(at: [indexPath], with: .automatic)
            }
            present(vc, animated: true)
        }
    }
}

extension HabitViewController: UITextFieldDelegate {
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
            errorHeightConstraint?.isActive = false
            return false
        }
        
        errorLabel.isHidden = true
        errorHeightConstraint?.isActive = true
        return true
    }
}

extension HabitViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case emojiCollectionView: emojis.count
        case colorsCollectionView: colors.count
        default: 0
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
                print("NewHabitViewController.collectionView: could not create Header View")
                return UICollectionReusableView()
            }
            headerView.config(with: NSLocalizedString("emoji", comment: "text for emoji section header"))
            return headerView
        case colorsCollectionView:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ColorSectionHeaderView.reuseIdentifier, for: indexPath) as? ColorSectionHeaderView else {
                print("NewHabitViewController.collectionView: could not create Header View")
                return UICollectionReusableView()
            }
            headerView.config(with: NSLocalizedString("color", comment: "text for color section header"))
            return headerView
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case emojiCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier, for: indexPath) as? EmojiCollectionViewCell else {
                print("NewHabitViewController.collectionView: could not create cell")
                return UICollectionViewCell()
            }
            cell.config(with: emojis[indexPath.row])
            return cell
        case colorsCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier, for: indexPath) as? ColorCollectionViewCell else {
                print("NewHabitViewController.collectionView: could not create cell")
                return UICollectionViewCell()
            }
            cell.config(with: colors[indexPath.row])
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case emojiCollectionView:
            trackerEmoji = emojis[indexPath.row]
        case colorsCollectionView:
            trackerColor = colors[indexPath.row]
        default:
            break
        }
    }

    
}

extension HabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
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
    
    private func getNumberOfLines(leftBorder: CGFloat, rightBorder: CGFloat, numberOfItems: Int, itemWidth: CGFloat, interItemSpace: CGFloat) -> Int{
        let totalWidth = view.bounds.width - leftBorder - rightBorder + interItemSpace
        let itemsInLine = Int(totalWidth/(itemWidth + interItemSpace))
        let lines = (numberOfItems + itemsInLine - 1) / itemsInLine
        return lines
    }
    
    private func getHeightForCollectionView(numberOfItems: Int) -> CGFloat{
        let headerHeight = getHeightForHeader()
        let totalLines = getNumberOfLines(leftBorder: 18, rightBorder: 18, numberOfItems: numberOfItems, itemWidth: 52, interItemSpace: 5)
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

