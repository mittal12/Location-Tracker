//
//  colorExtension.swift
//  LocationTracker
//
//  Created by Ashish Mittal  on 09/04/17.
//  Copyright © 2017 Ashish Mittal . All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

class colorExtension
{
    static let START_COLOR = "#FA645F"
    static let END_COLOR = "#31CD00"
}

class String_Globals{
    static let TITLE = "Home"
    static let END_SHIFT_TEXT = "swipe left to end shift"
    static let START_SHIFT_TEXT =  "swipe right to start shift"
    static let START_TITLE = "StartPoint"
    static let END_TITLE = "EndPoint"
    static let SUBTITLE = "I am here"
}
