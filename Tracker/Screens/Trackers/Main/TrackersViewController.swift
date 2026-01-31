//
//  TrackersViewController.swift
//  Tracker
//

import UIKit

final class TrackersViewController: UIViewController {
    
    private let dateLabel = UILabel()
    private let datePicker = UIDatePicker()
    private let trackersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let containerForEmptyResult = UIView()
    private let emptyResultImageView = UIImageView()
    private let emptyResultLabel = UILabel()
    private let filterButton = UIButton()
    private let searchBar = UISearchBar()
    private var searchBarLeading: NSLayoutConstraint!
    private var searchBarTrailing: NSLayoutConstraint!
    private var searchBarTop: NSLayoutConstraint!
    private var searchBarBottom: NSLayoutConstraint!
    
    private lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: effect)
        view.isHidden = true
        view.alpha = 0
        let overlay = UIView()
        overlay.isUserInteractionEnabled = false
        overlay.backgroundColor = UIColor(white: 1.0, alpha: 0.01)
        view.contentView.addSubviews([overlay])
        NSLayoutConstraint.activate([
            overlay.leadingAnchor.constraint(equalTo: view.contentView.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.contentView.trailingAnchor),
            overlay.topAnchor.constraint(equalTo: view.contentView.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.contentView.bottomAnchor)
        ])
        return view
    }()
    
    
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let analyticsService = AnalyticsService()
    
    private var categories: [TrackerCategory] = []{
        didSet {
            updateExistStateOn(currentDate)
        }
    }
    private var completedTrackers: [TrackerRecord] = []
    private var currentCompletedTrackerIds: Set<UUID> = []
    private var currentCategories: [TrackerCategory] = [] {
        didSet {
            updateEmptyState()
            trackersCollectionView.reloadData()
        }
    }
    
    private var currentDate = Date().normDate {
        didSet {
            updateExistStateOn(currentDate)
        }
    }
    
    private var isExistTrackersOnDay = true {
        didSet {
            filterButton.isHidden = !isExistTrackersOnDay
            emptyResultImageView.image = isExistTrackersOnDay ? UIImage(resource: .nothing) : UIImage(resource: .dizzy)
            emptyResultLabel.text = isExistTrackersOnDay ? NSLocalizedString("empty_search", comment: "text for empty searching result") : NSLocalizedString("empty_message", comment: "text for empty trackers view")
        }
    }
    
    private var filter: Filters? {
        get {
            guard let rawValue = UserDefaults.standard.string(forKey: Filters.key) else  { return nil }
            return Filters(rawValue: rawValue)
        }
        set {
            UserDefaults.standard.set(newValue?.rawValue, forKey: Filters.key)
            updateFilterState(newValue: newValue)
        }
    }
    
    private var isEditingSearch = false
    
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ru_RU")
        df.calendar = Calendar(identifier: .gregorian)
        df.timeZone = .current
        df.dateFormat = "dd.MM.yy"
        return df
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isEditingSearch { return }
        let searchTextField = searchBar.searchTextField
        if searchTextField.bounds.width > 1 && searchTextField.bounds.height > 1 {
            let insets = searchBar.searchBarFieldInsets()
            searchBarLeading.constant = -insets.left
            searchBarTrailing.constant = insets.right
            searchBarTop.constant = 7-insets.top
            searchBarBottom.constant = -10+insets.bottom
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.view.setNeedsLayout()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .TrWhiteDay
        
        trackerStore.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(handleCategoryChange), name: .trackerCategoryDidChange, object: nil)
        
        categories = trackerStore.getTrackers()
        
        do {
            completedTrackers = try trackerRecordStore.fetchAll()
        }
        catch {
            print("TrackersViewController.viewDidLoad: failed to fetch completed trackers - \(error)")
        }
        
        currentCompletedTrackerIds = Set(
            completedTrackers
                .filter{$0.date == currentDate}
                .map{$0.id}
        )
        
        currentCategories = getTrackersOnDate(currentDate, with: filter)
//UI
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
        setupSearchBar()
        headerContainer.addSubviews([titleLabel, searchBar])
        
        setupContainerForEmptyResult()
        setupTrackersCollectionView()
        setupFilterButton()
        
        view.addSubviews([headerContainer, containerForEmptyResult, trackersCollectionView, filterButton])
        
        view.addSubviews([blurView])
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        searchBarLeading = searchBar.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor)
        searchBarTrailing = searchBar.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor)
        searchBarTop = searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor)
        searchBarBottom = searchBar.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor)
        
        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            headerContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            headerContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            
            searchBarTop,
            searchBarLeading,
            searchBarTrailing,
            searchBarBottom,
            
            containerForEmptyResult.topAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            containerForEmptyResult.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            containerForEmptyResult.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            containerForEmptyResult.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            trackersCollectionView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        analyticsService.sendEvent(screenName: String(describing: type(of: self)), event: .open)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        analyticsService.sendEvent(screenName: String(describing: type(of: self)), event: .close)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .trackerCategoryDidChange, object: nil)
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        analyticsService.sendEvent(screenName: String(describing: type(of: self)), event: .click, item: "add_track")
        let vc = HabitViewController(isNewHabitMode: true)
        vc.saveHabit = { [weak self] tracker, category in
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
        currentCompletedTrackerIds = Set(
            completedTrackers
                .filter{$0.date == currentDate}
                .map{$0.id}
        )
        currentCategories = getTrackersOnDate(currentDate, with: filter)
    }
    
    @objc private func handleCategoryChange() {
        trackerStore.refetch()
    }
    
    @objc private func filterButtonTapped(){
        analyticsService.sendEvent(screenName: String(describing: type(of: self)), event: .click, item: "filter")
        let vc = FiltersViewController()
        vc.filterDidSelect = {[weak self] selectedFilter in
            self?.filter = selectedFilter
        }
        vc.selectedFilter = filter
        present(vc,animated: true)
    }
    
    // MARK: - Helpers
    
    private func updateExistStateOn(_ date: Date) {
        guard let day = date.weekDay() else {
            print("TrackersViewController.updateExistStateOn: Error converting date to week day")
            return
        }
        isExistTrackersOnDay = categories.contains {
            $0.trackers.contains {
                $0.schedule.contains(day)
            }
        }
    }
    
    private func getTrackersOnDate(_ date: Date, with filter: Filters?) -> [TrackerCategory]{
        var currentCategories: [TrackerCategory] = []
        if !isExistTrackersOnDay {
            return []
        }
        
        guard let day = date.weekDay() else {
            print("TrackersViewController.getTrackersOnDate: Error converting date to week day")
            return[]
        }
        
        categories.forEach { category in
            let trackers = category.trackers.filter {
                $0.schedule.contains(day) && matches(tracker: $0, filter: filter)
            }
            if trackers.count > 0 {
                let currentCategory = TrackerCategory(title: category.title, trackers: trackers)
                currentCategories.append(currentCategory)
            }
        }
        return currentCategories
    }
    
    private func matches(tracker: Tracker, filter: Filters?) -> Bool {
        guard let filter else { return true }
        switch filter{
        case .canceled: return currentCompletedTrackerIds.contains(tracker.id)
        case .notCanceled: return !currentCompletedTrackerIds.contains(tracker.id)
        default: return true
        }
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
        containerForEmptyResult.isHidden = !isEmpty
        trackersCollectionView.isHidden = isEmpty
    }
    
    private func updateFilterState(newValue: Filters?){
        if newValue == .today {
            datePicker.setDate(Date().normDate, animated: true)
            datePicker.sendActions(for: .valueChanged)
        } else {
            currentCategories = getTrackersOnDate(currentDate, with: newValue)
        }
        if newValue == .canceled || newValue == .notCanceled {
            filterButton.setTitleColor(.TrRed, for: .normal)
        } else {
            filterButton.setTitleColor(.white, for: .normal)
        }
    }
    
    // MARK: - UI setup
    
    private func setupTrackersCollectionView(){
        trackersCollectionView.delegate = self
        trackersCollectionView.dataSource = self
        trackersCollectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier)
        trackersCollectionView.register(TrackersCollectionEmptyViewCell.self, forCellWithReuseIdentifier: TrackersCollectionEmptyViewCell.reuseIdentifier)
        trackersCollectionView.register(TrackersSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackersSectionHeaderView.reuseIdentifier)
        trackersCollectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        trackersCollectionView.backgroundColor = .TrWhiteDay
    }
    
    private func createDatePickerContainer() -> UIView{
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.backgroundColor = .clear
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        updateDateLabelText(with: datePicker.date)
        
        let emptyView = UIView()
        emptyView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        emptyView.layer.cornerRadius = 8
        emptyView.isUserInteractionEnabled = false
        
        dateLabel.textColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        dateLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        dateLabel.textAlignment = .center
        dateLabel.backgroundColor = UIColor(red: 118.0/255.0, green: 118.0/255.0, blue: 128.0/255.0, alpha: 0.12)
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
        titleLabel.text = NSLocalizedString("trackers_title", comment: "text for trackers view controller title")
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = .TrBlackDay
        return titleLabel
    }
    
    private func setupSearchBar(){
        searchBar.delegate = self
        
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
            string: NSLocalizedString("search", comment: "text field placeholder"),
            attributes: [
                .foregroundColor: UIColor.TrGray,
                .font: UIFont.systemFont(ofSize: 17)
            ]
        )
    }
    
    private func setupContainerForEmptyResult(){
        containerForEmptyResult.backgroundColor = .clear
        let picture = createPictureContainer()
        containerForEmptyResult.addSubviews([picture])
        
        NSLayoutConstraint.activate([
            picture.centerXAnchor.constraint(equalTo: containerForEmptyResult.centerXAnchor),
            picture.centerYAnchor.constraint(equalTo: containerForEmptyResult.centerYAnchor),
            picture.leadingAnchor.constraint(greaterThanOrEqualTo: containerForEmptyResult.leadingAnchor),
            picture.trailingAnchor.constraint(lessThanOrEqualTo: containerForEmptyResult.trailingAnchor)
        ])
    }
    
    private func createPictureContainer() -> UIView {
        emptyResultImageView.image = isExistTrackersOnDay ? UIImage(resource: .nothing) : UIImage(resource: .dizzy)
        emptyResultLabel.text = isExistTrackersOnDay ? NSLocalizedString("empty_search", comment: "text for empty searching result") : NSLocalizedString("empty_message", comment: "text for empty trackers view")
        emptyResultLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptyResultLabel.textColor = .TrBlackDay
        let container = UIView()
        container.backgroundColor = .clear
        container.addSubviews([emptyResultImageView, emptyResultLabel])
        
        NSLayoutConstraint.activate([
            emptyResultImageView.topAnchor.constraint(equalTo: container.topAnchor),
            emptyResultImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            emptyResultLabel.topAnchor.constraint(equalTo: emptyResultImageView.bottomAnchor, constant: 8),
            emptyResultLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            emptyResultLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            emptyResultLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func setupFilterButton(){
        filterButton.backgroundColor = .TrBlue
        filterButton.layer.cornerRadius = 16
        filterButton.layer.masksToBounds = true
        if filter == .canceled || filter == .notCanceled {
            filterButton.setTitleColor(.TrRed, for: .normal)
        } else {
            filterButton.setTitleColor(.white, for: .normal)
        }
        filterButton.setTitle(NSLocalizedString("filters", comment: ""),for: .normal)
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
    }
    
}

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return currentCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfTrackers = currentCategories[safe: section]?.trackers.count ?? 0
        if section == currentCategories.count - 1 {
            return numberOfTrackers + 2
        } else {
            return numberOfTrackers
        }
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
        if indexPath.row >= currentCategories[indexPath.section].trackers.count {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  TrackersCollectionEmptyViewCell.reuseIdentifier, for: indexPath) as? TrackersCollectionEmptyViewCell else {
                print("TrackersViewController.collectionView: couldn't create cell")
                return UICollectionViewCell()
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  TrackersCollectionViewCell.reuseIdentifier, for: indexPath) as? TrackersCollectionViewCell else {
                print("TrackersViewController.collectionView: couldn't create cell")
                return UICollectionViewCell()
            }
            configCell(cell, for: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let category = currentCategories[indexPath.section]
        guard let tracker = currentCategories[indexPath.section].trackers[safe: indexPath.row] else { return nil }
        
        let configuration = UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) {[weak self] _ in
            let edit = UIAction(title: NSLocalizedString("edit", comment: "text for edit button")) { [weak self] _ in
                guard let self else { return }
                self.analyticsService.sendEvent(screenName: String(describing: type(of: self)), event: .click, item: "edit")
                let vc = HabitViewController(isNewHabitMode: false, tracker: tracker, category: category.title)
                vc.saveHabit = { [weak self] tracker, category in
                    guard let self else {return}
                    do {
                        let isCategoryExist = try self.trackerCategoryStore.isExistingCategory(withTitle: category)
                        if !isCategoryExist {
                            try self.trackerCategoryStore.addToStore(category)
                        }
                    }
                    catch {
                        print("HabitViewController.saveHabit: failed to check is category exist - \(error)")
                        return
                    }
                    do {
                        try self.trackerStore.updateInStore(tracker, categoryName: category)
                    }
                    catch {
                        print("HabitViewController.saveHabit: failed to save tracker - \(error)")
                    }
                }
                self.present(vc,animated: true)
            }
            
            let delete = UIAction(title: NSLocalizedString("delete", comment: "Delete"),
                                  attributes: .destructive) { [weak self] _ in
                guard let self else { return }
                self.analyticsService.sendEvent(screenName: String(describing: type(of: self)), event: .click, item: "delete")
                let sheet = DeleteItemSheetViewController(confirmLabelText: NSLocalizedString("item_delete_confirm_tracker", comment: "text for confirm delete action")){ [weak self] in
                    do {
                        try self?.trackerStore.deleteFromStore(id: tracker.id)
                    }
                    catch {
                        print("DeleteItemSheetViewController.onDelete: failed to delete tracker from store - \(error)")
                    }
                }
                sheet.modalPresentationStyle = .overFullScreen
                sheet.modalTransitionStyle = .crossDissolve
                self.present(sheet, animated: true)
            }
            
            return UIMenu(title: "", children: [edit, delete])
        }
        return configuration
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackersCollectionViewCell  else { return nil }
        return UITargetedPreview(view: cell.trackerView)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackersCollectionViewCell else { return nil }
        return UITargetedPreview(view: cell.trackerView)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplayContextMenu configuration: UIContextMenuConfiguration,
                        animator: (any UIContextMenuInteractionAnimating)?) {
        blurView.isHidden = false
        animator?.addAnimations { [weak self] in
            self?.blurView.alpha = 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willEndContextMenuInteraction configuration: UIContextMenuConfiguration,
                        animator: (any UIContextMenuInteractionAnimating)?) {
        animator?.addAnimations { [weak self] in
            self?.blurView.alpha = 0
        }
        animator?.addCompletion { [weak self] in
            self?.blurView.isHidden = true
        }
    }
    
    private func configCell(_ cell: TrackersCollectionViewCell, for indexPath: IndexPath) {
        let tracker = currentCategories[indexPath.section].trackers[indexPath.row]
        let daysCount = countOfDaysForTracker(withId: tracker.id, date: currentDate)
        let isCompleted = currentCompletedTrackerIds.contains(tracker.id)
        cell.config(description: tracker.name, emoji: tracker.emoji, color: tracker.color, daysCount: daysCount, isCompleted: isCompleted)
        cell.onButtonTap = { [weak self] in
            guard let self else {return}
            analyticsService.sendEvent(screenName: String(describing: type(of: self)), event: .click, item: "track")
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
        let insets: CGFloat = 16 + 16
        let totalWidth = collectionView.bounds.width - insets
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
        currentCategories = getTrackersOnDate(currentDate, with: filter)
    }
}

extension TrackersViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isEditingSearch = true
        searchBar.setShowsCancelButton(true, animated: true)
        emptyResultImageView.image = UIImage(resource: .nothing)
        emptyResultLabel.text = NSLocalizedString("empty_search", comment: "text for empty searching result")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isEditingSearch = false
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        currentCategories = getTrackersOnDate(currentDate, with: filter)
        emptyResultImageView.image = UIImage(resource: .dizzy)
        emptyResultLabel.text = NSLocalizedString("empty_message", comment: "text for empty trackers view")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var categoriesAfterFilter: [TrackerCategory] = []
        guard let searchText = searchBar.text else { return }
        let сategoriesBeforeFilter = getTrackersOnDate(currentDate, with: filter)
        if !searchText.isEmpty {
            сategoriesBeforeFilter.forEach{ category in
                let trackers = category.trackers.filter{$0.name.lowercased().contains(searchText.lowercased())}
                if trackers.count > 0 {
                    categoriesAfterFilter.append(TrackerCategory(title: category.title, trackers: trackers))
                }
            }
            currentCategories = categoriesAfterFilter
        } else {
            currentCategories = сategoriesBeforeFilter
        }
    }
    
}


