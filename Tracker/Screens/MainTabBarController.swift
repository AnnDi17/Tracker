//
//  ViewController.swift
//  Tracker
//

import UIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.layer.borderWidth = 1
        tabBar.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        
        let statisticViewController = StatisticViewController()
        let statisticNavigationController = UINavigationController(rootViewController: statisticViewController)
        
        let trackersViewController = TrackersViewController()
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        
        self.viewControllers = [trackersNavigationController,statisticNavigationController]
        
        let inactiveImageStat = UIImage(resource: .barStatInact).withRenderingMode(.alwaysOriginal)
        let activeImageStat = UIImage(resource: .barStatAct).withRenderingMode(.alwaysOriginal)
        statisticViewController.tabBarItem = UITabBarItem(title: "Статистика", image: inactiveImageStat, selectedImage: activeImageStat)
        
        let inactiveImageTrack = UIImage(resource: .barTrackInact).withRenderingMode(.alwaysOriginal)
        let activeImageTrack = UIImage(resource: .barTrackAct).withRenderingMode(.alwaysOriginal)
        trackersNavigationController.tabBarItem = UITabBarItem(title: "Трекеры", image: inactiveImageTrack, selectedImage: activeImageTrack)
        
    }
    
}
