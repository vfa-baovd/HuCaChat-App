//
//  AddUsersViewController.swift
//  Demo_Chat
//
//  Created by HungNV on 4/30/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import Firebase
import EZAlertController

class AddUsersViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!

    lazy var downloadPhotoQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Download avatar add user"
        queue.maxConcurrentOperationCount = 2
        
        return queue
    }()
    var users: [UserModel] = [UserModel]()
    var selected = Dictionary<String, String>()
    var downloadingTasks = Dictionary <IndexPath, Operation>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.enableSwipe = true
        self.startLoading()
        self.setupView()
        listenUpdateFromFirebase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsHelper.shared.setGoogleAnalytic(name: kGAIScreenName, value: "add_users_screen")
        AnalyticsHelper.shared.setFirebaseAnalytic(screenName: "add_users_screen", screenClass: classForCoder.description())
    }
    
    func setupView() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = Theme.shared.color_App()
        setupNavigation()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.allowsMultipleSelection = false
    }
    
    func setupNavigation() {
        setupNavigationBar(vc: self, title: Define.shared.getNameAddUsersScreen().uppercased(), leftText: nil, leftImg: #imageLiteral(resourceName: "arrow_back"), leftSelector: #selector(self.actBack(btn:)), rightText: nil, rightImg: #imageLiteral(resourceName: "icon_check"), rightSelector: #selector(self.actAddUsers(btn:)), isDarkBackground: true, isTransparent: true)
    }
    
    func actBack(btn: UIButton) {
        _ = navigationController?.popViewController(animated: true)
        
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "group", action: "add_users", label: "back", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "group", action: "add_users", label: "back")
    }
    
    func actAddUsers(btn: UIBarButtonItem) {
        if selected.isEmpty {
            EZAlertController.alert(kAppName, message: NSLocalizedString("h_sms_select_users", ""))
        } else {
            let controllers = self.navigationController?.viewControllers
            for vc in controllers! {
                if vc is CreateGroupViewController {
                    let createGroupVC = vc as! CreateGroupViewController
                    createGroupVC.usersSelected = selected
                    _ = self.navigationController?.popToViewController(createGroupVC, animated: true)
                }
            }
        }
        
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "group", action: "add_users", label: "add", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "group", action: "add_users", label: "add")
    }
    
    func setupData(completion:(_ success:Bool) -> Void) {
        let currentUserId = self.currentuserID
        self.ref.child("Users").observeSingleEvent(of: .value, with: { (snap) in
            if !(snap.value is NSNull) {
                guard let userArr = snap.children.allObjects as? [FIRDataSnapshot] else { return }
                for userSnap in userArr {
                    if userSnap.key == currentUserId { continue }
                    
                    guard let userDict = userSnap.value as? [String:AnyObject] else { return }
                    
                    if let user = UserModel(uid: userSnap.key, jsonData: userDict) {
                        self.users.append(user)
                    }
                }
                self.tableView.reloadData()
            }
            self.stopLoading()
        })
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
                    var isExit = false
                    for user in self.users {
                        if snap.key == user.id {
                            isExit = true
                            break
                        }
                    }
                    
                    if !isExit {
                        if snap.key != FIRAuth.auth()?.currentUser?.uid {
                            if let user = UserModel(uid: snap.key, jsonData: userDict) {
                                self.users.append(user)
                                self.tableView.reloadData()
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

extension AddUsersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath) as! AddUsersCell
        
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
        
        var isSelected = false
        for id in selected.keys {
            if id == user.id {
                isSelected = true
                break
            }
        }
        
        cell.configUser(user: user, myIndex: indexPath, isSelected: isSelected)
        cell.delegate = self
        
        return cell
    }
}

extension AddUsersViewController: UITableViewDelegate {
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

extension AddUsersViewController: DownloadPhotoOperationDelegate {
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

extension AddUsersViewController: AddUsersCellDelegate {
    func isContainUserSelected(user: UserModel) -> Bool {
        for id in selected.keys {
            if id == user.id {
                selected.removeValue(forKey: id)
                return true
            }
        }
        return false
    }
    
    func tappedCheckView(myIndex: IndexPath) {
        let selectedUser = self.users[myIndex.row]
        if !isContainUserSelected(user: selectedUser) {
            selected[selectedUser.id] = selectedUser.display_name
        }
        self.tableView.reloadRows(at: [myIndex], with: .none)
        
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "group", action: "add_users", label: "select_user", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "group", action: "add_users", label: "select_user")
    }
}
