//
//  LaunchScreenViewController.swift
//  Tracker
//

import UIKit

class LaunchScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .TrBlue
        let logoImageView = UIImageView(image: UIImage(resource: .launchScreenLogo))
        view.addSubviews([logoImageView])
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
