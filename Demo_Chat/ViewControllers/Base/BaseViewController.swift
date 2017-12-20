//
//  BaseViewController.swift
//  Demo_Chat
//
//  Created by Nguyen Van Hung on 2/14/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import NCMB
import Firebase

class BaseViewController: UIViewController {
    
    lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    var peopleOfGeneralChannel: FIRDatabaseReference!
    var messageChannel: FIRDatabaseReference!
    let storageLocal = FIRStorage.storage().reference()
    var keyboardHidden = true
    
    var enableSwipe: Bool = false {
        didSet {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = enableSwipe
        }
    }
    
    var currentuserID:String {
        if let currentuserID = FIRAuth.auth()?.currentUser?.uid {
            return currentuserID
        }
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch _ as NSError {}
        return ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(type(of: self))
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        if (appDelegate.currUser == nil && self.currentuserID != "") {
            self.getCurrentUser()
        }
        
        peopleOfGeneralChannel = ref.child("Conversations").child(Define.shared.getGeneralChannelKey()).child("people")
        
        NotificationCenter.default.addObserver(self, selector: #selector(showNotification(notification:)), name: NSNotification.Name(rawValue: kNotificationShowMessage), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReachable), name: NSNotification.Name(rawValue: kNotificationReachable), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotReachable), name: NSNotification.Name(rawValue: kNotificationNotReachable), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func getCurrentUser() {
        self.ref.child("Users").child(self.currentuserID).observeSingleEvent(of: .value, with: { (snap) in
            guard let userDict = snap.value as? [String:AnyObject] else { return }
            
            if let user = UserModel(uid: self.currentuserID, jsonData: userDict) {
                self.appDelegate.currUser = user
            }
        })
    }
    
    func redirectToHomeVC() {
        let homeVC = UIManager.shared.vcToSetFirst()
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    
    func dismissViewController() {
        self.dismiss(animated: true, completion: {})
    }
    
    func addUserInfo(user: FIRUser, userInfo: [String:Any], isDismiss: Bool) {
        var flag = false
        peopleOfGeneralChannel.observeSingleEvent(of: .value, with: { (snap) in
            if let users: [FIRDataSnapshot] = snap.children.allObjects as? [FIRDataSnapshot] {
                if users.count > 0 {
                    for userSnap in users {
                        if userSnap.key == user.uid {
                            flag = true
                            break
                        }
                    }
                    
                    if !flag {
                        self.ref.child("Users").child(user.uid).setValue(userInfo, withCompletionBlock: { (error, data) in
                            if error == nil {
                                self.peopleOfGeneralChannel.childByAutoId().setValue(user.uid)
                                self.stopLoading()
                                if isDismiss {
                                    self.dismissViewController()
                                } else {
                                    self.redirectToHomeVC()
                                }
                            }
                        })
                    } else {
                        self.stopLoading()
                        if isDismiss {
                            self.dismissViewController()
                        } else {
                            self.redirectToHomeVC()
                        }
                    }
                } else {
                    self.ref.child("Users").child(user.uid).setValue(userInfo, withCompletionBlock: { (error, data) in
                        if error == nil {
                            self.peopleOfGeneralChannel.childByAutoId().setValue(user.uid)
                            self.stopLoading()
                            if isDismiss {
                                self.dismissViewController()
                            } else {
                                self.redirectToHomeVC()
                            }
                        }
                    })
                }
            }
        })
    }
    
    func createNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyBoard(notification:) ), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyBoard(notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.tapScreen), name: NSNotification.Name.init("closeKeyboard"), object: nil)
    }
    
    
    func tapScreen() {
        if !keyboardHidden {
            self.view.endEditing(true)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func willShowKeyBoard(notification : NSNotification){
        keyboardHidden = false
        let userInfo: NSDictionary! = notification.userInfo as NSDictionary!
        
        var duration: TimeInterval = 0
        
        duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let keyboardFrame = (userInfo.object(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue).cgRectValue
        
        handleKeyboardWillShow(duration: duration,keyBoardRect: keyboardFrame)
    }
    
    func willHideKeyBoard(notification : NSNotification){
        keyboardHidden = true
        var userInfo: NSDictionary!
        userInfo = notification.userInfo as NSDictionary!
        
        var duration: TimeInterval = 0
        duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        let keyboardFrame = (userInfo.object(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue).cgRectValue
        
        handleKeyboardWillHide(duration: duration, keyBoardRect: keyboardFrame)
    }
    
    func handleKeyboardWillShow(duration: TimeInterval, keyBoardRect: CGRect) {}
    func handleKeyboardWillHide(duration: TimeInterval, keyBoardRect: CGRect) {}
    
    func showNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let title = userInfo["title"], let subTitle = userInfo["subTitle"] {
                CRNotifications.showNotification(type: .success, title: title as! String, message: subTitle as! String, dismissDelay: 4)
            }
        }
    }
    
    func handleReachable() {
        CRNotifications.showNotification(type: .success, title: "", message: NSLocalizedString("h_connected", ""), dismissDelay: 4)
    }
    
    func handleNotReachable() {
        CRNotifications.showNotification(type: .success, title: "", message: NSLocalizedString("h_lost_connection", ""), dismissDelay: 4)
        self.clearAllNotice()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension BaseViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
