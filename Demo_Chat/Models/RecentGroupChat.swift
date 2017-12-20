//
//  RecentGroupChat.swift
//  Demo_Chat
//
//  Created by HungNV on 5/1/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import Foundation

struct RecentGroupChat {
    static let default_avt = "https://firebasestorage.googleapis.com/v0/b/appchat20170215.appspot.com/o/avatar_default_group.png?alt=media&token=d29357b0-4910-4d5c-8de7-660689b5d63c"
    var id: String = ""
    var avatar_url: String = default_avt
    var avatar_img: UIImage?
    var name: String = ""
    var time_interval : NSDate = NSDate()
    var last_message: String = ""
    var people : Dictionary<String, String>?
    
    init?(id: String, jsonData:[String:AnyObject]) {
        guard let name = jsonData["name"] as? String else { return nil }
        
        if let avatar_url = jsonData["avatar"] as? String {
            self.avatar_url = avatar_url
        }
        
        if let last_message = jsonData["lastMessage"] as? String {
            self.last_message = last_message
        }
        
        if let time_interval = jsonData["lastTimeUpdated"] as? Double {
            self.time_interval = NSDate(timeIntervalSince1970: time_interval)
        }
        
        self.id = id
        self.name = name
        self.people = jsonData["people"] as? [String:String]
    }
}
