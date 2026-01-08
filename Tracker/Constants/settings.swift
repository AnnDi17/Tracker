import UIKit

enum Settings {
    private static let onboardingKey = "isOnboardingShown"
    
    static var isOnboardingShown: Bool {
        get {
            if UserDefaults.standard.object(forKey: onboardingKey) == nil {
                true
            } else {
                UserDefaults.standard.bool(forKey: onboardingKey)
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: onboardingKey)
        }
    }
}
