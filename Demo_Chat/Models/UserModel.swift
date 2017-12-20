//
//  UserModel.swift
//  Demo_Chat
//
//  Created by Nguyen Van Hung on 2/27/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import Foundation

struct UserModel {
    static let default_avt = "https://firebasestorage.googleapis.com/v0/b/appchat20170215.appspot.com/o/avatar_default.png?alt=media&token=cb676261-389e-4fdf-9c9c-c06f3a6f1eb5"
    var id : String
    var display_name : String
    var avatar_url : String = default_avt
    var avatar_img: UIImage?
    var email : String
    var is_online : String?
    var time_interval : NSDate = NSDate()
    var login_date : NSDate = NSDate()
    var status : String = ""
    var provider : String = "Firebase"
    var conversations : Dictionary<String, String>?
    var groups = [String:String]()
    var block_users = [String:String]()
    
    
    init?(uid: String, jsonData:[String : AnyObject]) {
        guard let display_name = jsonData["display_name"] as? String, let email = jsonData["email"] as? String else { return nil }
        
        if let avatar_url = jsonData["avatar"] as? String {
            self.avatar_url = avatar_url
        }
        
        if let is_online = jsonData["is_online"] as? String {
            self.is_online = is_online
        }
        
        if let time_interval = jsonData["time_interval"] as? Double {
            self.time_interval = NSDate(timeIntervalSince1970: time_interval)
        }
        
        if let login_date = jsonData["login_date"] as? Double {
            self.login_date = NSDate(timeIntervalSince1970: login_date)
        }
        
        if let status = jsonData["status"] as? String {
            self.status = status
        }
        
        if let provider = jsonData["provider"] as? String {
            self.provider = provider
        }
        
        if let groups = jsonData["groups"] as? [String:String] {
            self.groups = groups
        }
        
        if let blocks = jsonData["block_users"] as? [String:String] {
            self.block_users = blocks
        }
        
        self.id = uid
        self.display_name = display_name
        self.email = email
        
        self.conversations = jsonData["conversations"] as? [String : String]
    }
}
