//
//  PushModel.swift
//  Demo_Chat
//
//  Created by HungNV on 7/28/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import Foundation
import NCMB

struct PushModel {
    var id: String
    var send_id: String
    var receive_id: String
    var room_id: String
    var message_id: String
    var push_title: String
    var message_content: String
    var read_status: Bool
    var create_date: Date
    var update_date: Date
    
    init?(object: NCMBObject) {
        guard let id = object.objectId,
            let create_date = object.createDate,
            let update_date = object.updateDate,
            let send_id = object.object(forKey: "send_id") as? String,
            let receive_id = object.object(forKey: "receive_id") as? String,
            let room_id = object.object(forKey: "room_id") as? String,
            let message_id = object.object(forKey: "message_id") as? String,
            let push_title = object.object(forKey: "push_title") as? String,
            let message_content = object.object(forKey: "message_content") as? String,
            let read_status = object.object(forKey: "read_status") as? Bool else { return nil }
        
        self.id = id
        self.send_id = send_id
        self.receive_id = receive_id
        self.room_id = room_id
        self.message_id = message_id
        self.push_title = push_title
        self.message_content = message_content
        self.read_status = read_status
        self.create_date = create_date
        self.update_date = update_date
    }
}
