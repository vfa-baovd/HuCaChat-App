//
//  Message.swift
//  Demo_Chat
//
//  Created by Nguyen Van Hung on 3/2/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import Foundation

enum MessageType {
    case Text, Photo
}

struct Message {
    var message_id: String
    var sender_id: String
    var content: String
    var message_type: MessageType = .Text
    var create_date: NSDate = NSDate()
    
    var img_name: String?
    var img_width: Int = 0
    var img_height: Int = 0
    
    init?(message_id: String, message_info: [String:AnyObject]) {
        guard let sender_id = message_info["sender_id"] as? String else { return nil }
        guard let content = message_info["content"] as? String else { return nil }
        guard let time = message_info["create_date"] as? Double else { return nil }
        
        self.sender_id = sender_id
        self.content = content
        self.message_id = message_id
        
        if let date: NSDate = NSDate(timeIntervalSince1970: time) {
            self.create_date = date
        }
        
        if let message_type = message_info["message_type"] as? String {
            if message_type == "text" {
                self.message_type = .Text
            } else if message_type == "photo" {
                self.message_type = .Photo
                self.img_name = message_info["img_name"] as? String
                self.img_width = (message_info["img_width"] as? Int) ?? 0
                self.img_height = (message_info["img_height"] as? Int) ?? 0
            }
        }
    }
}
