//
//  TrackersViewController.swift
//  Tracker
//

import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - UI
    //private let datePicker = UIDatePicker()
    private let dateLabel = UILabel()
    private let trackersCollectionView = UICollectionView(frame:.zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let contentContainer = UIView()
    // private let dateContainer = UIView()
    
    // MARK: - Data
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var currentCategories: [TrackerCategory] = [] //{ categories.filter(\.self.isEditing) }
    
    // MARK: - Formatting
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ru_RU")
        df.calendar = Calendar(identifier: .gregorian)
        df.timeZone = .current
        df.dateFormat = "dd.MM.yy"
        return df
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .TrWhiteDay
        
        let trackers = [
            Tracker(
                id: 1,
                name: "Поливать растения",
                color: UIColor(red: 51/255, green: 207/255, blue: 105/255, alpha: 1),
                emoji: "🐱",
                schedule: ["Monday"]
            ),
            
            Tracker(
                id: 2,
                name: "Test2",
                color: UIColor(red: 255/255, green: 136/255, blue: 30/255, alpha: 1),
                emoji: "🐱",
                schedule: ["Фитнес"]
            )
        ]
        
        let testCategory1 = TrackerCategory(
            title: "Домашний уют",
            trackers: trackers
        )
        
        categories.append(testCategory1)
        
        currentCategories = getTrackers()
        contentContainer.isHidden = !currentCategories.isEmpty
        
        trackersCollectionView.delegate = self
        trackersCollectionView.dataSource = self
        trackersCollectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationItem.leftBarButtonItem?.image = UIImage(resource: .addTracker).withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem?.tintColor = .TrBlackDay
        
        let dateContainer = createDatePickerContainer()
        //let datePickerView = createDatePicker()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dateContainer)
        
        let headerContainer = UIView()
        headerContainer.backgroundColor = .clear
        let titleLabel = createTitleLabel()
        let searchBar = createSearchField()
        headerContainer.addSubviews([titleLabel, searchBar])
        
        contentContainer.backgroundColor = .clear
        let picture = createPictureContainer()
        contentContainer.addSubviews([picture])
        
        view.addSubviews([headerContainer, contentContainer, trackersCollectionView])
        
        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            headerContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            headerContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            searchBar.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -10),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            
            contentContainer.topAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            contentContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            contentContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            picture.centerXAnchor.constraint(equalTo: contentContainer.centerXAnchor),
            picture.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor),
            picture.leadingAnchor.constraint(greaterThanOrEqualTo: contentContainer.leadingAnchor),
            picture.trailingAnchor.constraint(lessThanOrEqualTo: contentContainer.trailingAnchor),
            
            trackersCollectionView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func getTrackers() -> [TrackerCategory]{
        var currentCategories: [TrackerCategory] = []
        categories.forEach{category in
            let trackers = category.trackers.filter{$0.id%2 > 0}
            if trackers.count > 0 {
                let currentCategory = TrackerCategory(title: category.title, trackers: trackers)
                currentCategories.append(currentCategory)
            }
        }
        //currentCategories = categories.filter { $0.trackers.filter{$0.id%2 > 0}.count > 0 }
        return currentCategories
    }
    
    private func countOfDaysForTracker(withId id: UInt) -> Int {
        return 10
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        updateDateLabelText(with: sender.date)
    }
    
    // MARK: - UI setup
    private func createDatePicker() -> UIView{
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        let datePickerView = UIView()
        datePickerView.addSubviews([datePicker])
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: datePickerView.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: datePickerView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: datePickerView.trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: datePickerView.bottomAnchor)
        ])
        
        return datePickerView
    }
    
    private func createDatePickerContainer() -> UIView{
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        //datePicker.tintColor = .clear
        datePicker.backgroundColor = .clear
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        updateDateLabelText(with: datePicker.date)
        
        let emptyView = UIView()
        emptyView.backgroundColor = .TrWhiteDay
        emptyView.isUserInteractionEnabled = false
        
        dateLabel.textColor = .TrBlackDay
        dateLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        dateLabel.textAlignment = .center
        dateLabel.backgroundColor = UIColor(red: 118/255, green: 118/255, blue: 128/255, alpha: 0.12)
        dateLabel.isUserInteractionEnabled = false
        
        let dateContainer = UIView()
        dateContainer.backgroundColor = .clear
        //dateContainer.layer.cornerRadius = 8
        //dateContainer.layer.masksToBounds = true
        dateContainer.isOpaque = false
        
        dateContainer.addSubviews([datePicker, emptyView, dateLabel])
        
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: dateContainer.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: dateContainer.trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: dateContainer.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: dateContainer.bottomAnchor),
            
            emptyView.leadingAnchor.constraint(equalTo: dateContainer.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: dateContainer.trailingAnchor),
            emptyView.topAnchor.constraint(equalTo: dateContainer.topAnchor),
            emptyView.bottomAnchor.constraint(equalTo: dateContainer.bottomAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: dateContainer.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: dateContainer.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: dateContainer.topAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: dateContainer.bottomAnchor),
            //dateContainer.heightAnchor.constraint(equalToConstant: 34)
        ])
        
        return dateContainer
    }
    
    private func updateDateLabelText(with date: Date) {
        dateLabel.text = dateFormatter.string(from: date)
    }
    
    private func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = "Трекеры"
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = .black
        return titleLabel
    }
    
    private func createSearchField() -> UISearchBar {
        let searchBar = UISearchBar()
        
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .clear
        searchBar.isTranslucent = true
        
        let textField = searchBar.searchTextField
        textField.backgroundColor = UIColor(red: 118/255, green: 118/255, blue: 128/255, alpha: 0.12)
        textField.borderStyle = .none
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = true
        textField.textColor = .TrBlackDay
        textField.leftView?.tintColor = .TrGray
        textField.attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: [
                .foregroundColor: UIColor.TrGray,
                .font: UIFont.systemFont(ofSize: 17)
            ]
        )
        return searchBar
    }
    
    private func createPictureContainer()->UIView{
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .dizzy)
        
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .TrBlackDay
        let container = UIView()
        container.backgroundColor = .clear
        container.addSubviews([imageView, label])
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            /*imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
             imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),*/
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        
        return container
    }
    
}

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfSections section: Int) -> Int {
        return currentCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  TrackersCollectionViewCell.reuseIdentifier, for: indexPath) as? TrackersCollectionViewCell else {
            print("collectionView: couldn't create cell")
            return UICollectionViewCell()
        }
        configCell(cell, for: indexPath)
        return cell
    }
    
    private func configCell(_ cell: TrackersCollectionViewCell, for indexPath: IndexPath) {
        let tracker = currentCategories[indexPath.section].trackers[indexPath.row]
        let daysCount = countOfDaysForTracker(withId: tracker.id)
        cell.config(description: tracker.name, emoji: tracker.emoji, color: tracker.color, daysCount: daysCount)
    }
    
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.bounds.width / 2
        let size = CGSize(width: width, height: 148)
        return size
    }
}

