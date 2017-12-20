//
//  ApplicationModel.swift
//  Demo_Chat
//
//  Created by HungNV on 8/16/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import Foundation
import NCMB

struct ApplicationModel {
    var id: String
    var app_name: String
    var app_url: String
    var app_icon: String
    var app_category: String
    var release_date: String
    var create_date: Date
    var update_date: Date
    
    init?(object: NCMBObject) {
        guard let id = object.objectId,
            let create_date = object.createDate,
            let update_date = object.updateDate,
            let app_name = object.object(forKey: "app_name") as? String,
            let app_url = object.object(forKey: "app_url") as? String,
            let app_icon = object.object(forKey: "app_icon") as? String,
            let app_category = object.object(forKey: "app_category") as? String,
            let release_date = object.object(forKey: "release_date") as? String else { return nil }
        
        self.id = id
        self.app_name = app_name
        self.app_url = app_url
        self.app_icon = app_icon
        self.app_category = app_category
        self.release_date = release_date
        self.create_date = create_date
        self.update_date = update_date
    }
}
