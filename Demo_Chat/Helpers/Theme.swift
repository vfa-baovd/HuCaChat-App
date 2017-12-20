//
//  Theme.swift
//  Demo_Chat
//
//  Created by Nguyen Van Hung on 2/5/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

enum FontSize: CGFloat {
    case extraExtraLarge = 78.0
    case extraLarge = 54.0
    case veryVeryLarge = 42.0
    case veryLarge = 30.0
    case larger = 24.0
    case large = 20.0
    case medium = 18.0
    case small = 16.0
    case smaller = 14.0
    case tiny = 12.0
}

let fontBold = "Gotham Bold"
let fontMedium = "Gotham Medium"

class Theme: AnyObject {
    static let shared = Theme()
    
    //MARK:- Font
    func getFontBold() -> String {
        return fontBold
    }
    
    func getFontMedium() -> String {
        return fontMedium
    }
    
    func font_primaryLight(size: FontSize) -> UIFont {
        return UIFont(name: self.getFontMedium(), size: size.rawValue)!
    }
    
    func font_primaryRegular(size: FontSize) -> UIFont {
        return UIFont(name: self.getFontMedium(), size: size.rawValue)!
    }
    
    func font_primaryBold(size: FontSize) -> UIFont {
        return UIFont(name: self.getFontBold(), size: size.rawValue)!
    }
    
    //MARK:- Color
    func color_App() -> UIColor {
        return UIColor(hex: "2998FF", a: 1.0)
    }
    
    func color_Navigator() -> UIColor {
        return UIColor(hex: "49A6FD", a: 1.0)
    }
    
    func color_Dark_App() -> UIColor {
        return UIColor(hex: "0096E2", a: 1.0)
    }
    
    func color_Online() -> UIColor {
        return UIColor(hex: "36B581", a: 1.0)
    }
    
    func color_Offline() -> UIColor {
        return UIColor.lightGray
    }
    
    func color_Away() -> UIColor {
        return UIColor(hex: "EFBE4D", a: 1.0)
    }
    
    func color_Busy() -> UIColor {
        return UIColor(hex: "EB5160", a: 1.0)
    }
    
    func color_BottonScroll() -> UIColor {
        return UIColor(hex: "FFCD00", a: 1.0)
    }
    
    func color_avaiable() -> UIColor {
        return UIColor(hex: "E9E9E9", a: 1.0)
    }
    
    func color_download() -> UIColor {
        return UIColor(hex: "7eff57", a: 1.0)
    }
    
    func color_downloaded() -> UIColor {
        return UIColor(hex: "E9E9E9", a: 1.0)
    }
    
    func color_delete() -> UIColor {
        return UIColor(hex: "ff575f", a: 1.0)
    }
}
