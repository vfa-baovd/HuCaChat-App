//
//  NSBundle+LocalizedString.swift
//  Demo_Chat
//
//  Created by HungNV on 8/22/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import Foundation

let NSLocalizedString: (_ key: String, _ comment: String?) -> String = Bundle.main.localizedString

extension Bundle {
    public func localizedString(key: String, replaceValue: String?) -> String {
        var falbackBundlePath: String = ""
        var currentLanguage: String = ""
        let language = Helper.shared.currentLanguageCode()
        
        if language == LANGUAGE_CODE_AUTO {
            currentLanguage = LANGUAGE_CODE_EN
        } else {
            currentLanguage = language
        }
        
        if let fbP = Bundle.main.path(forResource: currentLanguage, ofType: "lproj") {
            falbackBundlePath = fbP
            if let fallbackBundle: Bundle = Bundle(path: falbackBundlePath) {
                falbackBundlePath = fallbackBundle.localizedString(forKey: key, value: replaceValue, table: nil)
                return falbackBundlePath
            }
        }
        
        return falbackBundlePath
    }
}
