//
//  OnboardingViewController.swift
//  Tracker
//

import UIKit

final class OnboardingViewController: UIViewController {
    
    private let imageForScreen: UIImage
    private let textForScreen: String
    private let onButtonTaped: ()->Void
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .TrBlackDay
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle("Вот это технологии!", for: .normal)
        button.tintColor = .TrWhiteDay
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        button.backgroundColor = .TrBlackDay
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        
        return button
    }()
    
    init(image: UIImage, text: String, action: @escaping () -> Void){
        imageForScreen = image
        textForScreen = text
        onButtonTaped = action
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = textForScreen
        backgroundImageView.image = imageForScreen
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        view.addSubviews([backgroundImageView,titleLabel,button])
        setupLayout()
    }
    
    @objc private func buttonTapped(){
        onButtonTaped()
    }
    
    private func setupLayout(){
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            button.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 160),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 60),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }
    
    
}
