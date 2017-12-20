//
//  ProductionCountries.swift
//  Demo_Chat
//
//  Created by HungNV on 8/15/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import Foundation

struct ProductionCountries {
    var id: String = ""
    var name:String = ""
    
    init?(jsonData: JSONData) {
        guard let id = jsonData["iso_3166_1"] as? String else {return nil}
        self.id = id
        
        if let name = jsonData["name"] as? String {
            self.name = name
        }
    }
}
