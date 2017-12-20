//
//  PushHelper.swift
//  Demo_Chat
//
//  Created by HungNV on 5/21/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import Foundation
import NCMB

class PushHelper: NSObject {
    static let shared = PushHelper()
    
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func pushHistory(receive_user: [String], send_id: String, room_id: String, message_id: String, push_type: String, message_content: String, completionHandler: @escaping(Error?) -> Void) {
        var numFinished = 0
        for receive_id in receive_user {
            let query = NCMBQuery.init(className: PUSH_CLASS)
            query?.whereKey("receive_id", equalTo: receive_id)
            query?.whereKey("send_id", equalTo: send_id)
            query?.whereKey("room_id", equalTo: room_id)
            query?.whereKey("message_id", equalTo: message_id)
            query?.findObjectsInBackground({ (objects, error) in
                if error == nil {
                    if objects?.count ?? 0 > 0 {
                        let obj = objects?[0] as! NCMBObject
                        obj.setObject(receive_id, forKey: "receive_id")
                        obj.setObject(send_id, forKey: "send_id")
                        obj.setObject(room_id, forKey: "room_id")
                        obj.setObject(message_id, forKey: "message_id")
                        obj.setObject(self.createTitleMessage(), forKey: "push_title")
                        obj.setObject(message_content, forKey: "message_content")
                        obj.setObject(false, forKey: "read_status")
                        obj.saveInBackground({ (error) in
                            if (error == nil) {
                                self.sendPush(receive_id: receive_id, room_id: room_id, push_type: push_type, message_content: message_content, completionHandler: { (error) in
                                    if (error == nil) {
                                        numFinished += 0
                                        if numFinished == receive_user.count {
                                            completionHandler(error)
                                        }
                                    } else {
                                        completionHandler(error)
                                    }
                                })
                            } else {
                                completionHandler(error)
                            }
                        })
                    } else {
                        let obj = NCMBObject.init(className: PUSH_CLASS)
                        obj?.setObject(receive_id, forKey: "receive_id")
                        obj?.setObject(send_id, forKey: "send_id")
                        obj?.setObject(room_id, forKey: "room_id")
                        obj?.setObject(message_id, forKey: "message_id")
                        obj?.setObject(self.createTitleMessage(), forKey: "push_title")
                        obj?.setObject(message_content, forKey: "message_content")
                        obj?.setObject(false, forKey: "read_status")
                        obj?.saveInBackground({ (error) in
                            if (error == nil) {
                                self.sendPush(receive_id: receive_id, room_id: room_id, push_type: push_type, message_content: message_content, completionHandler: { (error) in
                                    if (error == nil) {
                                        numFinished += 0
                                        if numFinished == receive_user.count {
                                            completionHandler(error)
                                        }
                                    } else {
                                        completionHandler(error)
                                    }
                                })
                            } else {
                                completionHandler(error)
                            }
                        })
                    }
                } else {
                    completionHandler(error)
                }
            })
        }
    }
    
    func sendPush(receive_id: String, room_id: String, push_type: String, message_content: String, completionHandler: @escaping(Error?) -> Void) {
        let data:[String:AnyObject] = [
            "contentAvailable": false as AnyObject,
            "badgeIncrementFlag": true as AnyObject,
            "sound": "default" as AnyObject,
            "action": "ReceiveActivity" as AnyObject,
            "title": kAppName as AnyObject
        ]
        
        let push = NCMBPush.init()
        push.setData(data)
        let query = NCMBInstallation.query()
        query?.whereKey("user_id", equalTo: receive_id)
        query?.whereKey("allow_push", equalTo: true)
        push.setSearchCondition(query)
        push.setMessage(message_content)
        push.setUserSettingValue(["push_type": push_type, "room_chat": room_id])
        push.setImmediateDeliveryFlag(true)
        push.setPushToIOS(true)
        push.setPushToAndroid(true)
        push.sendInBackground({ (error) in
            if error == nil {
                completionHandler(error)
            } else {
                completionHandler(error)
            }
        })
    }
    
    func createTitleMessage() -> String {
        let send_name = appDelegate.currUser?.display_name ?? ""
        
        return send_name
    }
}
