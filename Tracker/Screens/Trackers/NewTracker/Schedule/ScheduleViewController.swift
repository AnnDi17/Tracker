//
//  ScheduleViewController.swift
//  Tracker
//


import UIKit

final class ScheduleViewController: UIViewController {
    
    var daysDidSelect: (([WeekDay]) -> Void)?
    
    private var weekDays: [(WeekDay,Bool)] = [(.mon,false),(.tue,false),(.wed,false),(.thu,false),(.fri,false),(.sat,false),(.sun,false)]
    
    private let daysTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .TrWhiteDay
        
        let titleLabel = getTitleLabel()
        
        setupDaysTableView()
        
        let okButton = getOkButton()
        
        view.addSubviews([titleLabel, daysTableView, okButton])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            daysTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            daysTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            daysTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            daysTableView.heightAnchor.constraint(equalToConstant: 75*7),
            
            okButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            okButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            okButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            okButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupDaysTableView(){
        daysTableView.dataSource = self
        daysTableView.delegate = self
        daysTableView.register(DaysTableViewCell.self, forCellReuseIdentifier: DaysTableViewCell.reuseIdentifier)
        daysTableView.layer.cornerRadius = 16
        daysTableView.layer.masksToBounds = true
        daysTableView.tableFooterView = UIView(frame: .init(x: 0, y: 0, width: 0, height: 0.01))
        daysTableView.isScrollEnabled = false
    }
    
    
    private func getTitleLabel() -> UILabel{
        let label = UILabel()
        label.text = "Расписание"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .TrBlackDay
        return label
    }
    
    private func getOkButton() -> UIButton{
        let button = UIButton()
        button.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor.TrWhiteDay, for: .normal)
        button.backgroundColor = .TrBlackDay
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }
    
    @objc private func okButtonTapped(){
        let days = weekDays.filter{$0.1}
        var selectedDays: [WeekDay] = []
        days.forEach {
            selectedDays.append($0.0)
        }
        daysDidSelect?(selectedDays)
        dismiss(animated: true, completion: nil)
    }
    
}

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = daysTableView.dequeueReusableCell(withIdentifier: DaysTableViewCell.reuseIdentifier, for: indexPath) as? DaysTableViewCell else {
            print("ScheduleViewController.tableView: Error dequeuing cell")
            return UITableViewCell()
        }
        var day = ""
        switch indexPath.row{
        case 0:
            day = "Понедельник"
        case 1:
            day = "Вторник"
        case 2:
            day = "Среда"
        case 3:
            day = "Четверг"
        case 4:
            day = "Пятница"
        case 5:
            day = "Суббота"
        default:
            day = "Воскресенье"
        }
        cell.config(with: day)
        cell.valueDidChange = {[weak self] isDayIncluded in
            self?.weekDays[indexPath.row].1 = isDayIncluded
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
