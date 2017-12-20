//
//  BlockUsersViewController.swift
//  Demo_Chat
//
//  Created by HungNV on 5/4/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import Firebase
import EZAlertController

class BlockUsersViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var downloadPhotoQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Download avatar unblock user"
        queue.maxConcurrentOperationCount = 2
        
        return queue
    }()
    var users: [UserModel] = [UserModel]()
    var downloadingTasks = Dictionary <IndexPath, Operation>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        
        self.listenUpdateFromFirebase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsHelper.shared.setGoogleAnalytic(name: kGAIScreenName, value: "block_users_screen")
        AnalyticsHelper.shared.setFirebaseAnalytic(screenName: "block_users_screen", screenClass: classForCoder.description())
    }
    
    func setupView() {
        self.setupNavigation()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.allowsMultipleSelection = false
    }
    
    func setupNavigation() {
        setupNavigationBar(vc: self, title: Define.shared.getNameBlockUsersScreen().uppercased(), leftText: nil, leftImg: #imageLiteral(resourceName: "arrow_back"), leftSelector: #selector(self.actBack(btn:)), rightText: nil, rightImg: nil, rightSelector: nil, isDarkBackground: true, isTransparent: true)
    }
    
    func actBack(btn: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func listenUpdateFromFirebase() {
        updateUserInfo()
        addUserInfo()
        deleteUserInfo()
    }
    
    func updateUserInfo() {
        self.ref.child("Users").observe(.childChanged, with: { (snap) in
            if !(snap.value is NSNull) {
                if self.users.count > 0 {
                    if let userInfo = snap.value as? [String:AnyObject] {
                        if let user = UserModel(uid: snap.key, jsonData: userInfo) {
                            
                            //TH update status
                            for i in 0..<self.users.count {
                                if user.id == self.users[i].id {
                                    self.users[i] = user
                                    let indexPath = IndexPath(row: i, section: 0)
                                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    func addUserInfo() {
        self.ref.child("Users").observe(.childAdded, with: { (snap) in
            if !(snap.value is NSNull) {
                if let userDict = snap.value as? [String:AnyObject] {
                    if let block_user = self.appDelegate.currUser?.block_users {
                        for id in block_user.values {
                            if id == snap.key {
                                if let user = UserModel(uid: snap.key, jsonData: userDict) {
                                    self.users.append(user)
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                    self.stopLoading()
                }
            }
        })
    }
    
    func deleteUserInfo() {
        self.ref.child("Conversations").child(Define.shared.getGeneralChannelKey()).child("people").observe(.childRemoved, with: { (snap) in
            if !(snap.value is NSNull) {
                if self.users.count > 0 {
                    if let uid = snap.value as? String {
                        for i in 0..<self.users.count {
                            let user:UserModel = self.users[i]
                            if uid == user.id {
                                self.users.remove(at: i)
                                self.tableView.beginUpdates()
                                let indexPath = NSIndexPath(row: i, section: 0)
                                self.tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
                                self.tableView.endUpdates()
                            }
                        }
                    }
                }
            }
        })
    }
    
    func startDownloadImage(operation: DownloadPhotoOperation) {
        if let _ = downloadingTasks[operation.indexPath] {
            return
        }
        
        downloadingTasks[operation.indexPath] = operation
        downloadPhotoQueue.addOperation(operation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension BlockUsersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath) as! BlockUsersCell
        
        var user = self.users[indexPath.row]
        if let image = Helper.shared.getCachedImageForPath(fileName: "\(user.id).jpg") {
            user.avatar_img = image
            self.users[indexPath.row] = user
        } else {
            if !tableView.isDecelerating {
                let downloadPhoto = DownloadPhotoOperation(indexPath: indexPath, photoURL: user.avatar_url, delegate: self)
                startDownloadImage(operation: downloadPhoto)
            }
        }
        cell.configUser(user: self.users[indexPath.row], myIndex: indexPath)
        cell.delegateBlock = self
        
        let viewSwipe = Helper.shared.viewWithImgName(img: #imageLiteral(resourceName: "icon_unblock"))
        let defaultColor = Theme.shared.color_Online()
        
        cell.setSwipeGesture(viewSwipe, color: defaultColor, mode: .switch, state: .state1, completionHandler: { (cell, state, mode) in
            if cell is BlockUsersCell, let c = cell as? BlockUsersCell {
                self.swipeToClip(indexPath: c.myIndex)
            }
        })
        
        return cell
    }
    
    // MARK:  Delete delegate
    func swipeToClip(indexPath: IndexPath) {
        let user = self.users[indexPath.row]
        EZAlertController.alert(kAppName, message: "\(NSLocalizedString("h_sms_unblock_user", "")) \(user.display_name)", buttons: [NSLocalizedString("h_cancel", ""), NSLocalizedString("h_unblock", "")]) { (alertAction, position) -> Void in
            if position == 0 {
                #if CHAT_DEV
                    print("Cancel")
                #endif
                
                AnalyticsHelper.shared.sendGoogleAnalytic(category: "more", action: "block_users", label: "cancel_unblock", value: nil)
                AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "more", action: "block_users", label: "cancel_unblock")
            } else if position == 1 {
                self.updateUnBlockUser(blockID: user.id)
                
                AnalyticsHelper.shared.sendGoogleAnalytic(category: "more", action: "block_users", label: "touch_unblock", value: nil)
                AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "more", action: "block_users", label: "touch_unblock")
            }
        }
        
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "more", action: "block_users", label: "message_confirm_unblock", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "more", action: "block_users", label: "message_confirm_unblock")
    }
    
    func updateUnBlockUser(blockID: String) {
        self.ref.child("Users").child(self.currentuserID).child("block_users").observeSingleEvent(of: .value, with: { (snap) in
            if let userArr = snap.value as? [String:String] {
                for userSnap in userArr {
                    if userSnap.value == blockID {
                        self.ref.child("Users/\(self.currentuserID)/block_users/\(userSnap.key)").removeValue()
                        self.getCurrentUser()
                        for i in 0..<self.users.count {
                            if blockID == self.users[i].id {
                                self.users.remove(at: i)
                                self.tableView.reloadData()
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationRefreshData), object: nil, userInfo: nil)
                                break
                            }
                        }
                    }
                }
            }
        })
    }
}

extension BlockUsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDecelerating {
            downloadPhotoQueue.cancelAllOperations()
            downloadingTasks.removeAll()
        }
    }
}

extension BlockUsersViewController: DownloadPhotoOperationDelegate {
    func downloadPhotoDidFail(operation: DownloadPhotoOperation) {
        print("Download faile")
    }
    
    func downloadPhotoDidFinish(operation: DownloadPhotoOperation, image: UIImage) {
        var user = self.users[operation.indexPath.row]
        
        let size = CGSize(width: 40, height: 40)
        let resultImg = image.scaleImage(size: size).createRadius(size: size, radius: size.width/2, byRoundingCorners: UIRectCorner.allCorners)
        user.avatar_img = resultImg
        self.users[operation.indexPath.row] = user
        
        Helper.shared.cacheImageThumbnail(image: resultImg, fileName: "\(user.id).jpg")
        self.tableView.reloadRows(at: [operation.indexPath], with: .automatic)
        downloadingTasks.removeValue(forKey: operation.indexPath)
    }
}

extension BlockUsersViewController: BlockUsersCellDelegate {
    func tappedContentView(myIndex: IndexPath) {
        //        let selectedUser = self.users[myIndex.row]
    }
}
