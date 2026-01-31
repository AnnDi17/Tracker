//
//  SceneDelegate.swift
//  Tracker
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        if Settings.isOnboardingShown {
            window?.rootViewController = OnboardingPageViewController()
        } else {
            window?.rootViewController = MainTabBarController()
        }
        window?.makeKeyAndVisible()
        guard let _ = (scene as? UIWindowScene) else { return }
    }


}

