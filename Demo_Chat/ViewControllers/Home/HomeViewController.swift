//
//  HomeViewController.swift
//  Demo_Chat
//
//  Created by Nguyen Van Hung on 2/5/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var bottomMenuView: BottomMenuView! = nil
    var users: [UserModel] = [UserModel]()
    var downloadingTasks = Dictionary <IndexPath, Operation>()
    var hidingNavBarHelper: HidingNavBarHelper?
    
    lazy var downloadPhotoQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Download avatar chat"
        queue.maxConcurrentOperationCount = 2
        
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.enableSwipe = true
        self.startLoading()
        self.navigationController?.navigationBar.isHidden = true
        self.setupView()
        listenUpdateFromFirebase()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name(rawValue: kNotificationRefreshData), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = Define.shared.getNameHomeScreen().uppercased()
        self.revealViewController().panGestureRecognizer().isEnabled = true
        
        bottomMenuView.clearSelectButton()
        bottomMenuView.btnHome.isSelected = true
        bottomMenuView.currentIndex = 0
        
        hidingNavBarHelper?.viewWillAppear(animated)
        
        AnalyticsHelper.shared.setGoogleAnalytic(name: kGAIScreenName, value: "home_chat_screen")
        AnalyticsHelper.shared.setFirebaseAnalytic(screenName: "home_chat_screen", screenClass: classForCoder.description())
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.revealViewController().panGestureRecognizer().isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hidingNavBarHelper?.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hidingNavBarHelper?.viewDidLayoutSubviews()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupNavigation() {
        setupNavigationBar(vc: self, title: Define.shared.getNameHomeScreen().uppercased(), leftText: nil, leftImg: #imageLiteral(resourceName: "icon_left_menu"), leftSelector: #selector(self.actLeftMenu(btn:)), rightText: nil, rightImg: #imageLiteral(resourceName: "icon_right_menu"), rightSelector: #selector(self.actRightMenu(btn:)), isDarkBackground: true, isTransparent: true)
    }
    
    func setupView() {
        self.setupNavigation()
        
        guard let revealVC = self.revealViewController() else { return }
        revealVC.panGestureRecognizer()
        revealVC.tapGestureRecognizer()
        
        bottomMenuView = BottomMenuView(delegate: nil)
        bottomMenuView.layer.shadowRadius = 5
        bottomMenuView.layer.shadowOpacity = 0.3
        bottomMenuView.layer.shadowColor = UIColor.gray.cgColor
        bottomMenuView.delegate = self
        self.view.addSubview(bottomMenuView)
        
        bottomMenuView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.allowsMultipleSelection = false
        DispatchQueue.main.async {
            self.tableView.frame.size.height = self.tableView.frame.size.height - self.bottomMenuView.frame.size.height
        }
        
        hidingNavBarHelper = HidingNavBarHelper(viewController: self, scrollView: tableView)
    }
    
    func refreshData() {
        self.users.removeAll()
        let currentUserId = self.currentuserID
        self.ref.child("Users").observeSingleEvent(of: .value, with: { (snap) in
            if !(snap.value is NSNull) {
                guard let userArr = snap.children.allObjects as? [FIRDataSnapshot] else { return }
                for userSnap in userArr {
                    if userSnap.key == currentUserId { continue }
                    
                    guard let userDict = userSnap.value as? [String:AnyObject] else { return }
                    
                    if let user = UserModel(uid: userSnap.key, jsonData: userDict) {
                        var isExist = false
                        if let block_user = self.appDelegate.currUser?.block_users {
                            for id in block_user.values {
                                if id == user.id {
                                    isExist = true
                                    break
                                }
                            }
                        }
                        
                        if !isExist {
                            self.users.append(user)
                        }
                    }
                }
                self.tableView.reloadData()
            }
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
                            
                            //TH update status
                            for i in 0..<self.users.count {
                                if user.id == self.users[i].id {
                                    self.users[i] = user
                                    let indexPath = IndexPath(row: i, section: 0)
                                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                                }
                            }
                            
                            //TH update block/unblock user
                            if user.id == self.currentuserID {
                                var listCount = self.users.count, i = 0
                                while i < listCount {
                                    var isExist = false
                                    
                                    for id in user.block_users.values {
                                        if id == self.users[i].id {
                                            isExist = true
                                            break
                                        }
                                    }
                                    
                                    if isExist {
                                        self.users.remove(at: i)
                                        listCount -= 1
                                        self.tableView.reloadData()
                                    } else {
                                        i += 1
                                    }
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
                    var isExist = false
                    for user in self.users {
                        if snap.key == user.id {
                            isExist = true
                            break
                        }
                    }
                    
                    if let block_user = self.appDelegate.currUser?.block_users {
                        for id in block_user.values {
                            if id == snap.key {
                                isExist = true
                                break
                            }
                        }
                    }
                    
                    if !isExist {
                        if snap.key != self.currentuserID {
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

    func actLeftMenu(btn: UIBarButtonItem) {
        self.revealViewController().revealToggle(btn)
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "home", action: "left_menu", label: "left_menu_button", value: nil)
    }
    
    func actRightMenu(btn: UIBarButtonItem) {
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "home", action: "right_menu", label: "right_menu_button", value: nil)
        self.revealViewController().rightRevealToggle(btn)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension HomeViewController: BottomMenuViewDelegate {
    func didSelectedBtnHome(_: BottomMenuView!) {
    
    }
    
    func didSelectedBtnCalendar(_: BottomMenuView!) {
        let groupVC = self.storyboard?.instantiateViewController(withIdentifier: "GroupVC") as! GroupViewController
        self.navigationController?.pushViewController(groupVC, animated: false)
    }
    
    func didSelectedBtnCenter(_: BottomMenuView!) {
    
    }
    
    func didSelectedBtnAlarm(_: BottomMenuView!) {
        let notificationVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationViewController
        self.navigationController?.pushViewController(notificationVC, animated: false)
    }
    
    func didSelectedBtnSetting(_: BottomMenuView!) {
        let moreVC = self.storyboard?.instantiateViewController(withIdentifier: "MoreVC") as! MoreViewController
        self.navigationController?.pushViewController(moreVC, animated: false)
    }
    
    func didSelectedBtnContact(_: BottomMenuView!) {
        let contactVC = self.storyboard?.instantiateViewController(withIdentifier: "ContactVC") as! ContactViewController
        self.navigationController?.pushViewController(contactVC, animated: true)
    }
    
    func didSelectedBtnVideo(_: BottomMenuView!) {
        let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "MapVC") as! MapViewController
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
    
    func didSelectedBtnCamera(_: BottomMenuView!) {
        let musicVC = self.storyboard?.instantiateViewController(withIdentifier: "MusicVC") as! MusicViewController
        self.navigationController?.pushViewController(musicVC, animated: true)
    }
    
    func didSelectedBtnCheckIn(_: BottomMenuView!) {
        let pageMenuVC = self.storyboard?.instantiateViewController(withIdentifier: "PageMenuVC") as! PageMenuViewController
        self.navigationController?.pushViewController(pageMenuVC, animated: true)
    }
    
    func didSelectedBtnCheckOut(_: BottomMenuView!) {
    
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath) as! ContactCell
        if self.users.count > indexPath.row {
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
            cell.delegate = self
        }
        
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDecelerating {
            downloadPhotoQueue.cancelAllOperations()
            downloadingTasks.removeAll()
        }
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        hidingNavBarHelper?.shouldScrollToTop()
        return true
    }
}

extension HomeViewController: DownloadPhotoOperationDelegate {
    func downloadPhotoDidFail(operation: DownloadPhotoOperation) {
        #if DEBUG
            print("Download faile")
        #endif
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

extension HomeViewController: ContactCellDelegate {
    func tappedContentView(myIndex: IndexPath) {
        let selectedUser = self.users[myIndex.row]
        self.pleaseWait()
        self.ref.child("Users").child(selectedUser.id).observeSingleEvent(of: .value, with: { (snap) in
            guard let userDict = snap.value as? [String:AnyObject] else { return }
            
            if let user = UserModel(uid: selectedUser.id, jsonData: userDict) {
                if let roomKey = user.conversations?[self.currentuserID] {
                    self.pushToChatDetails(roomKey: roomKey, receiverUser: user)
                } else {
                    self.createConversationWith(user: user)
                }
            }
        })
        
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "home", action: "chat", label: "start_chat", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "home", action: "chat", label: "start_chat")
    }
    
    func pushToChatDetails(roomKey: String, receiverUser: UserModel) {
        self.clearAllNotice()
        let messageVC = self.storyboard?.instantiateViewController(withIdentifier: "MessageVC") as! MessageViewController
        messageVC.conversationKey = roomKey
        messageVC.receiverUser = receiverUser
        self.navigationController?.pushViewController(messageVC, animated: true)
        
        var numShowAdMob = 0
        if let value = Helper.shared.getUserDefault(key: kShowAdMod) as? Int  {
            numShowAdMob = value + 1
            Helper.shared.saveUserDefault(key: kShowAdMod, value: numShowAdMob)
            if numShowAdMob % 3 == 0 {
                GoogleAdMobHelper.shared.showInterstitial()
            }
        } else {
            numShowAdMob += 1
            Helper.shared.saveUserDefault(key: kShowAdMod, value: numShowAdMob)
        }
    }
    
    func createConversationWith(user: UserModel) {
        let currentUID = self.currentuserID
        guard let currDisplayName = FIRAuth.auth()?.currentUser?.displayName else { return }
        
        let newRoomChatRef = self.ref.child("Conversations").childByAutoId()
        let conversationData = [
            "lastMessage": "",
            "lastTimeUpdated": NSDate().timeIntervalSince1970,
            "name": [
                currentUID: user.display_name,
                user.id: currDisplayName
            ],
            "people": [
                self.ref.childByAutoId().key: currentUID,
                self.ref.childByAutoId().key: user.id
            ]
            ] as [String: Any]
        
        newRoomChatRef.setValue(conversationData) { (error, ref) in
            if error == nil {
                self.ref.child("Users/\(user.id)/conversations/\(currentUID)").setValue(newRoomChatRef.key)
                self.ref.child("Users/\(currentUID)/conversations/\(user.id)").setValue(newRoomChatRef.key)
                self.pushToChatDetails(roomKey: newRoomChatRef.key, receiverUser: user)
            }
        }
    }
}
