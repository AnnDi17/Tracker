//
//  CategoriesViewController.swift
//  Tracker
//

import UIKit

final class CategoriesViewController: UIViewController {
    
    private var viewModel: CategoriesViewModel?
    
    private let categoriesTableView = UITableView()
    private var blurView: UIVisualEffectView?
    private var blurredIndexPath: IndexPath?
    
    var categoryDidSelect: ((String) -> Void)?
    var selectedCategory: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = CategoriesViewModel()
        viewModel?.onCategoriesDidChange = { [weak self] data in
            self?.categoriesTableView.reloadData()
        }
        viewModel?.onError = { [weak self] error in
            guard let self else { return }
            if let storeError = error as? TrackerCategoryStoreError, storeError == .hasLinkedTrackers {
                let alert = UIAlertController(title: "Нельзя удалить категорию",
                                              message: "К этой категории привязаны трекеры. Сначала удалите или перенесите трекеры.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок", style: .default))
                self.present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: "Ошибка",
                                              message: "Не удалось удалить категорию. Попробуйте позже.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок", style: .default))
                self.present(alert, animated: true)
            }
        }
        
        view.backgroundColor = .TrWhiteDay
        
        let titleLabel = getTitleLabel()
        setupCategoriesTableView()
        let addButton = getAddButton()
        view.addSubviews([titleLabel, categoriesTableView, addButton])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 14),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 49),
            
            categoriesTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoriesTableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupCategoriesTableView(){
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
        categoriesTableView.register(CategoriesTableViewCell.self, forCellReuseIdentifier: CategoriesTableViewCell.reuseIdentifier)
        categoriesTableView.layer.cornerRadius = 16
        categoriesTableView.layer.masksToBounds = false
        categoriesTableView.separatorStyle = .singleLine
        categoriesTableView.tableFooterView = UIView(frame: .init(x: 0, y: 0, width: 0, height: 0.01))
        categoriesTableView.backgroundColor = .clear
    }
    
    private func getTitleLabel() -> UILabel{
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "Категория"
        label.textColor = .TrBlackDay
        return label
    }
    
    private func getAddButton() -> UIButton{
        let button = UIButton()
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor.TrWhiteDay, for: .normal)
        button.backgroundColor = .TrBlackDay
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }
    
    @objc private func addButtonTapped(){
        let newCategoryVC = CategoryViewController(title: "Новая категория"){[weak self] name in
            self?.viewModel?.addCategoryToStore(name)
            self?.selectedCategory = name
        }
        present(newCategoryVC, animated: true, completion: nil)
    }
    
    private func showBlur(excluding indexPath: IndexPath, in tableView: UITableView) {
        hideBlur()
        tableView.layoutIfNeeded()
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blur.frame = view.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blur.isUserInteractionEnabled = false
        
        let cellRect = tableView.rectForRow(at: indexPath)
        let cellRectInView = tableView.convert(cellRect, to: view)
        
        if cellRectInView == .zero || !view.bounds.intersects(cellRectInView) {
            view.addSubview(blur)
            blurView = blur
            return
        }
        
        let path = UIBezierPath(rect: view.bounds)
        let holePath = UIBezierPath(roundedRect: cellRectInView, cornerRadius: 16)
        path.append(holePath)
        path.usesEvenOddFillRule = true
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        blur.layer.mask = maskLayer
        
        view.addSubview(blur)
        blurView = blur
    }
    
    private func hideBlur() {
        blurView?.removeFromSuperview()
        blurView = nil
        blurredIndexPath = nil
    }
}

extension CategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.categories.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoriesTableViewCell.reuseIdentifier, for: indexPath) as? CategoriesTableViewCell else {
            print("CategoriesViewController.tableView: Error dequeuing cell")
            return UITableViewCell()
        }
        guard let viewModel = viewModel?.categories[indexPath.row] else { return UITableViewCell() }
        cell.viewModel = viewModel
        cell.config(isChecked: viewModel.name == selectedCategory)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let count = viewModel?.categories.count, count > 0 else { return }
        
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
        guard let category = viewModel?.categories[indexPath.row].name else { return }
        categoryDidSelect?(category)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        blurredIndexPath = indexPath
        showBlur(excluding: indexPath, in: tableView)
        guard let category = viewModel?.categories[indexPath.row] else { return nil }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                guard let self else { return }
                let sheet = DeleteCategorySheetViewController()
                sheet.onDelete = { [weak self] in
                    self?.viewModel?.deleteFromStore(category)
                }
                sheet.modalPresentationStyle = .overFullScreen
                sheet.modalTransitionStyle = .crossDissolve
                self.present(sheet, animated: true)
                
            }
            let editAction = UIAction(title: "Редактировать") { _ in
                let editScreen = CategoryViewController(title: "Редактирование", textForTextField: category.name){[weak self] newTitle in
                    self?.viewModel?.editCategoryInStore(category, newName: newTitle)
                }
                self?.present(editScreen, animated: true)
            }
            return UIMenu(children: [editAction, deleteAction])
        }
    }
    
    func tableView(_ tableView: UITableView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        animator?.addCompletion { [weak self] in
            self?.hideBlur()
        }
    }
    
}

