//
//  colors.swift
//  Tracker
//

import UIKit

extension UIColor{
    static let TrWhiteDay = UIColor{ traits in
        if traits.userInterfaceStyle == .light {
            return  UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        } else {
            return UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)
        }
    }
    static let TrBlackDay = UIColor{ traits in
        if traits.userInterfaceStyle == .light {
            return UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)
        } else {
            return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        }
    }
    
    static let TrGray = UIColor{ traits in
        if traits.userInterfaceStyle == .light {
            return UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
        } else {
            return UIColor(red: 235/255, green: 235/255, blue: 245/255, alpha: 1)
        }
    }
    
    /*static let TrWhiteDay = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    static let TrBlackDay = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)
    static let TrGray = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)*/
   
    
    static let TrBlue = UIColor(red: 55/255, green: 114/255, blue: 231/255, alpha: 1)
    static let TrWhite = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    static let TrLightGray = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 1)
    static let TrBackgroundDay = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
    static let TrRed = UIColor(red: 245/255, green: 107/255, blue: 108/255, alpha: 1)
    
    static let TrSystemRed = UIColor(red: 255/255, green: 69/255, blue: 58/255, alpha: 1)
    static let TrSystemBlue = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
    static let TrSeparatorColor = UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.36)
    
}


