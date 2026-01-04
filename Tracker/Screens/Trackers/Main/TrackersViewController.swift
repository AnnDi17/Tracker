//
//  TrackersViewController.swift
//  Tracker
//

import UIKit

final class TrackersViewController: UIViewController {
    
    private let dateLabel = UILabel()
    private let trackersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let contentContainer = UIView()
    
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentCompletedTrackerIds: Set<UUID> = []
    private var currentCategories: [TrackerCategory] = [] {
        didSet {
            updateEmptyState()
            trackersCollectionView.reloadData()
        }
    }
    
    private var currentDate = Date().normDate
    
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
        trackerStore.delegate = self
        
        categories = trackerStore.getTrackers()
        
        do {
            completedTrackers = try trackerRecordStore.fetchAll()
        }
        catch {
            print("TrackersViewController.viewDidLoad: failed to fetch completed trackers - \(error)")
        }
        
        currentCategories = getTrackersOnDate(currentDate)
        
        currentCompletedTrackerIds = Set(
            completedTrackers
                .filter{$0.date == currentDate}
                .map{$0.id}
        )
        
        setupTrackersCollectionView()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationItem.leftBarButtonItem?.image = UIImage(resource: .addTracker).withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem?.tintColor = .TrBlackDay
        
        let dateContainer = createDatePickerContainer()
        dateContainer.frame = CGRect(x: 0, y: 0, width: 120, height: 34)
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
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        let vc = NewHabitViewController()
        vc.createHabit = { [weak self] tracker, category in
            guard let self else {return}
            do {
                let isCategoryExist = try self.trackerCategoryStore.isExistingCategory(withTitle: category)
                if !isCategoryExist {
                    try trackerCategoryStore.addToStore(category)
                }
            }
            catch {
                print("createHabit: failed to check is category exist - \(error)")
                return
            }
            do {
                try trackerStore.addToStore(tracker, categoryName: category)
            }
            catch {
                print("createHabit: failed to add tracker to store - \(error)")
            }
        }
        present(vc,animated: true)
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        updateDateLabelText(with: sender.date)
        currentDate = sender.date.normDate
        currentCategories = getTrackersOnDate(currentDate)
        currentCompletedTrackerIds = Set(
            completedTrackers
                .filter{$0.date == currentDate}
                .map{$0.id}
        )
    }
    
    // MARK: - Helpers
    private func weekDay(from date: Date) -> WeekDay? {
        let number = Calendar.current.component(.weekday, from: date)
        let corrected = number == 1 ? 7 : number - 1
        return WeekDay(rawValue: corrected)
    }
    
    private func getTrackersOnDate(_ date: Date) -> [TrackerCategory]{
        var currentCategories: [TrackerCategory] = []
        guard let day = weekDay(from: date) else {
            print("TrackersViewController.getTrackersOnDate: Error converting date to week day")
            return[]
        }
        categories.forEach{category in
            let trackers = category.trackers.filter{
                $0.schedule.contains(day)
            }
            if trackers.count > 0 {
                let currentCategory = TrackerCategory(title: category.title, trackers: trackers)
                currentCategories.append(currentCategory)
            }
        }
        return currentCategories
    }
    
    private func countOfDaysForTracker(withId id: UUID, date: Date) -> Int {
        let countOfDays = completedTrackers.count(where: { $0.id == id && $0.date <= date})
        return countOfDays
    }
    
    private func updateDateLabelText(with date: Date) {
        dateLabel.text = dateFormatter.string(from: date)
    }
    
    private func updateEmptyState() {
        let isEmpty = currentCategories.isEmpty
        contentContainer.isHidden = !isEmpty
        trackersCollectionView.isHidden = isEmpty
    }
    
    // MARK: - UI setup
    
    private func setupTrackersCollectionView(){
        trackersCollectionView.delegate = self
        trackersCollectionView.dataSource = self
        trackersCollectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier)
        trackersCollectionView.register(TrackersSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackersSectionHeaderView.reuseIdentifier)
    }
    
    private func createDatePickerContainer() -> UIView{
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
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
        dateLabel.layer.cornerRadius = 8
        dateLabel.layer.masksToBounds = true
        dateLabel.isUserInteractionEnabled = false
        
        let dateContainer = UIView()
        dateContainer.backgroundColor = .clear
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
            dateLabel.bottomAnchor.constraint(equalTo: dateContainer.bottomAnchor)
        ])
        
        return dateContainer
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
        textField.translatesAutoresizingMaskIntoConstraints = false
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
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            textField.topAnchor.constraint(equalTo: searchBar.topAnchor),
            textField.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor)
        ])
        
        return searchBar
    }
    
    private func createPictureContainer() -> UIView {
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
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
}

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return currentCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentCategories[safe: section]?.trackers.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                   withReuseIdentifier: TrackersSectionHeaderView.reuseIdentifier,
                                                                   for: indexPath)
        if let header = view as? TrackersSectionHeaderView {
            let title = currentCategories[safe:indexPath.section]?.title ?? ""
            header.configure(title: title)
        }
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  TrackersCollectionViewCell.reuseIdentifier, for: indexPath) as? TrackersCollectionViewCell else {
            print("TrackersViewController.collectionView: couldn't create cell")
            return UICollectionViewCell()
        }
        configCell(cell, for: indexPath)
        return cell
    }
    
    private func configCell(_ cell: TrackersCollectionViewCell, for indexPath: IndexPath) {
        let tracker = currentCategories[indexPath.section].trackers[indexPath.row]
        let daysCount = countOfDaysForTracker(withId: tracker.id, date: currentDate)
        let isCompleted = currentCompletedTrackerIds.contains(tracker.id)
        cell.config(description: tracker.name, emoji: tracker.emoji, color: tracker.color, daysCount: daysCount, isCompleted: isCompleted)
        cell.onButtonTap = { [weak self] in
            guard let self else {return}
            if self.currentDate > Date().normDate {return}
            if isCompleted {
                let newCompletedTrackers = self.completedTrackers.filter{ $0.id != tracker.id || $0.date != self.currentDate}
                self.completedTrackers = newCompletedTrackers
                self.currentCompletedTrackerIds.remove(tracker.id)
                do{
                    try self.trackerRecordStore.deleteFromStore(trackerId: tracker.id, date: self.currentDate)
                }
                catch {
                    print("onButtonTap: error deleting tracker record - \(error)")
                }
            } else {
                let trackerRecord = TrackerRecord(
                    id: tracker.id,
                    date: self.currentDate
                )
                self.completedTrackers.append(trackerRecord)
                self.currentCompletedTrackerIds.insert(tracker.id)
                do{
                    try self.trackerRecordStore.addToStore(trackerRecord)
                }
                catch {
                    print("onButtonTap: error saving tracker record - \(error)")
                }
            }
            self.trackersCollectionView.reloadItems(at: [indexPath])
        }
    }
    
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = collectionView.bounds.width
        let interItem: CGFloat = 9
        let availableWidth = totalWidth - interItem
        let itemWidth = floor(availableWidth / 2)
        return CGSize(width: itemWidth, height: 152)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        let top: CGFloat = 16
        let bottom: CGFloat = 12
        let lineHeight = UIFont.systemFont(ofSize: 19, weight: .bold).lineHeight
        let height = top + lineHeight + bottom
        return CGSize(width: collectionView.bounds.width, height: height)
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func store(_ store: TrackerStore) {
        categories = trackerStore.getTrackers()
        currentCategories = getTrackersOnDate(currentDate)
    }
}
