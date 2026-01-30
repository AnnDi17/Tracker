//
//  StatisticViewController.swift
//  Tracker
//

import UIKit

final class StatisticViewController: UIViewController {
    
    private var viewModel: StatisticViewModel?
    
    private let statisticTableView = UITableView()
    private let containerForEmptyResult = UIView()
    
    init(viewModel: StatisticViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init() {
        let viewModel = StatisticViewModel()
        self.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = StatisticViewModel()
        updateEmptyState()
        
        viewModel?.onStatisticDidChange = { [weak self] data in
            self?.statisticTableView.reloadData()
            self?.updateEmptyState()
        }
        
        view.backgroundColor = .TrWhiteDay
        
        let titleLabel = getTitleLabel()
        setupContainerForEmptyResult()
        setupStatisticTableView()
     
        view.addSubviews([titleLabel, containerForEmptyResult, statisticTableView])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            containerForEmptyResult.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            containerForEmptyResult.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            containerForEmptyResult.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            containerForEmptyResult.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            statisticTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            statisticTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            statisticTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            statisticTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func updateEmptyState() {
        guard let isEmpty = viewModel?.statistic.isEmpty else { return }
        containerForEmptyResult.isHidden = !isEmpty
        statisticTableView.isHidden = isEmpty
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
        let emptyImageView = UIImageView()
        let emptyLabel = UILabel()
        emptyImageView.image = UIImage(resource: .emptyStat)
        emptyLabel.text = NSLocalizedString("statistics_empty_message", comment: "text for empty statistic view")
        emptyLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptyLabel.textColor = .TrBlackDay
        let container = UIView()
        container.backgroundColor = .clear
        container.addSubviews([emptyImageView, emptyLabel])
        
        NSLayoutConstraint.activate([
            emptyImageView.topAnchor.constraint(equalTo: container.topAnchor),
            emptyImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
            emptyLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            emptyLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            emptyLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func setupStatisticTableView(){
        statisticTableView.dataSource = self
        statisticTableView.delegate = self
        statisticTableView.register(StatisticTableViewCell.self, forCellReuseIdentifier: StatisticTableViewCell.reuseIdentifier)
        statisticTableView.backgroundColor = .clear
    }
    
    private func getTitleLabel() -> UILabel{
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.text = NSLocalizedString("statistics_title", comment:"Text for statistic label")//"Статистика"
        label.textColor = .TrBlackDay
        return label
    }
    
}

extension StatisticViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel?.statistic.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticTableViewCell.reuseIdentifier, for: indexPath) as? StatisticTableViewCell else {
            print("StatisticViewController.tableView: Error dequeuing cell")
            return UITableViewCell()
        }
        guard let viewModel = viewModel?.statistic[indexPath.section] else { return UITableViewCell() }
        cell.viewModel = viewModel
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
}

import SwiftUI

#Preview {
    StatisticViewController()
}


