//
//  FiltersViewController.swift
//  Tracker
//

import UIKit

final class FiltersViewController: UIViewController {
    
    private let filtersTableView = UITableView()
    
    var filterDidSelect: ((Filters) -> Void)?
    var selectedFilter: Filters? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .TrWhiteDay
        
        let titleLabel = getTitleLabel()
        setupFiltersTableView()
        
        view.addSubviews([titleLabel, filtersTableView])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            filtersTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            filtersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filtersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filtersTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupFiltersTableView(){
        filtersTableView.dataSource = self
        filtersTableView.delegate = self
        filtersTableView.register(FiltersTableViewCell.self, forCellReuseIdentifier: FiltersTableViewCell.reuseIdentifier)
        filtersTableView.layer.cornerRadius = 16
        filtersTableView.layer.masksToBounds = false
        filtersTableView.separatorStyle = .singleLine
        filtersTableView.tableFooterView = UIView(frame: .init(x: 0, y: 0, width: 0, height: 0.01))
        filtersTableView.backgroundColor = .clear
        filtersTableView.allowsMultipleSelection = false
    }
    
    private func getTitleLabel() -> UILabel{
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = NSLocalizedString("filters", comment:"Text for screen title")
        label.textColor = .TrBlackDay
        return label
    }
    
}

extension FiltersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Filters.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FiltersTableViewCell.reuseIdentifier, for: indexPath) as? FiltersTableViewCell else {
            print("FiltersViewController.tableView: Error dequeuing cell")
            return UITableViewCell()
        }
        let isChecked = Filters.allCases[indexPath.row] == selectedFilter && selectedFilter != .all && selectedFilter != .today
        cell.config(isChecked: isChecked, title: Filters.allCases[indexPath.row].title)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let count = Filters.allCases.count
        
        let radius: CGFloat = 16
        let separatorLeftRight: CGFloat = 16
        cell.separatorInset = UIEdgeInsets(top: 0, left: separatorLeftRight, bottom: 0, right: separatorLeftRight)
        
        cell.contentView.layer.cornerRadius = 0
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.maskedCorners = []
        
        if indexPath.row == 0 && indexPath.row == count - 1 {
            cell.contentView.layer.cornerRadius = radius
            cell.contentView.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner,
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
        } else if indexPath.row == 0 {
            cell.contentView.layer.cornerRadius = radius
            cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if indexPath.row == count - 1 {
            cell.contentView.layer.cornerRadius = radius
            cell.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        
        cell.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        filterDidSelect?(Filters.allCases[indexPath.row])
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
}
