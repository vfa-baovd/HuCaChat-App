//
//  GroupViewController.swift
//  Demo_Chat
//
//  Created by HungNV on 4/30/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import Firebase

class GroupViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    var bottomMenuView: BottomMenuView! = nil
    var recentChats: [RecentGroupChat] = [RecentGroupChat]()
    var downloadingTasks = Dictionary <IndexPath, Operation>()
    var isPushToMessageID: String = ""
    
    lazy var downloadPhotoQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Download avatar chat"
        queue.maxConcurrentOperationCount = 2
        
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startLoading()
        self.setupView()
        self.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = Define.shared.getNameGroupScreen().uppercased()
        
        AnalyticsHelper.shared.setGoogleAnalytic(name: kGAIScreenName, value: "group_chat_screen")
        AnalyticsHelper.shared.setFirebaseAnalytic(screenName: "group_chat_screen", screenClass: classForCoder.description())
        
        if (isPushToMessageID != "") {
            self.loadData()
            self.pushToMessage(roomKey: isPushToMessageID)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isPushToMessageID = ""
    }

    func setupNavigation() {
        setupNavigationBar(vc: self, title: Define.shared.getNameGroupScreen().uppercased(), leftText: nil, leftImg: nil, leftSelector: nil, rightText: nil, rightImg: #imageLiteral(resourceName: "icon_add"), rightSelector: #selector(self.actAddGroup(btn:)), isDarkBackground: true, isTransparent: true)
    }
    
    func setupView() {
        self.setupNavigation()
        
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
        
        bottomMenuView.clearSelectButton()
        bottomMenuView.btnCalendar.isSelected = true
        bottomMenuView.currentIndex = 1
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.allowsMultipleSelection = false
        DispatchQueue.main.async {
            self.tableView.frame.size.height = self.tableView.frame.size.height - 50
        }
    }
    
    func loadData() {
        self.recentChats.removeAll()
        self.pleaseWait()
        
        let usersRef            = self.ref.child("Users")
        let conversationsRef    = self.ref.child("Conversations")
        
        usersRef.child(self.currentuserID).child("groups").observeSingleEvent(of: .value, with: { (snap) in
            if !(snap.value is NSNull) {
                if snap.children.allObjects.count == 0 {
                    self.clearAllNotice()
                    return
                }
                
                var numFinished = 0
                for item in snap.children.allObjects {
                    guard let recentSnap = item as? FIRDataSnapshot else { return }
                    let conversationKey = recentSnap.value as! String
                    conversationsRef.child(conversationKey).observeSingleEvent(of: .value, with: { (conversationSnap) in
                        if let recentInfo = conversationSnap.value as? [String:AnyObject] {
                            if let recentChat = RecentGroupChat(id: conversationKey, jsonData: recentInfo) {
                                self.recentChats.append(recentChat)
                            }
                        }
                        
                        numFinished += 1
                        if numFinished == snap.children.allObjects.count {
                            self.tableView.reloadData()
                            self.stopLoading()
                        }
                    })
                }
            } else {
                self.stopLoading()
            }
        })
    }
    
    func actAddGroup(btn: UIBarButtonItem) {
        let createGroupVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateGroupVC") as! CreateGroupViewController
        self.navigationController?.pushViewController(createGroupVC, animated: true)
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

extension GroupViewController: BottomMenuViewDelegate {
    func didSelectedBtnHome(_: BottomMenuView!) {
        let _ = self.navigationController?.popToRootViewController(animated: false)
    }
    
    func didSelectedBtnCalendar(_: BottomMenuView!) {
        
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

extension GroupViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recentChats.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath) as! RecentGroupCell
        
        var recentChat = self.recentChats[indexPath.row]
        if let image = Helper.shared.getCachedImageForPath(fileName: "\(recentChat.id).jpg") {
            recentChat.avatar_img = image
            self.recentChats[indexPath.row] = recentChat
        } else {
            if !tableView.isDecelerating {
                let downloadPhoto = DownloadPhotoOperation(indexPath: indexPath, photoURL: recentChat.avatar_url, delegate: self)
                startDownloadImage(operation: downloadPhoto)
            }
        }
        cell.configRecentGroupChat(recentGroup: recentChat, myIndex: indexPath)
        cell.delegate = self
        
        return cell
    }
}

extension GroupViewController: DownloadPhotoOperationDelegate {
    func downloadPhotoDidFail(operation: DownloadPhotoOperation) {
        #if DEBUG
            print("Download faile")
        #endif
    }
    
    func downloadPhotoDidFinish(operation: DownloadPhotoOperation, image: UIImage) {
        var recentChat = self.recentChats[operation.indexPath.row]
        
        let size = CGSize(width: 40, height: 40)
        let resultImg = image.scaleImage(size: size).createRadius(size: size, radius: size.width/2, byRoundingCorners: UIRectCorner.allCorners)
        
        recentChat.avatar_img = resultImg
        self.recentChats[operation.indexPath.row] = recentChat
        
        Helper.shared.cacheImageThumbnail(image: resultImg, fileName: "\(recentChat.id).jpg")
        self.tableView.reloadRows(at: [operation.indexPath], with: .automatic)
        downloadingTasks.removeValue(forKey: operation.indexPath)
    }
}

extension GroupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
}

extension GroupViewController: RecentGroupCellDelegate {
    func tappedContentView(myIndex: IndexPath) {
        let recentChat = self.recentChats[myIndex.row]
        self.pushToMessage(roomKey: recentChat.id)
        
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "group", action: "chat", label: "start_chat", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "group", action: "chat", label: "start_chat")
    }
    
    func pushToMessage(roomKey: String) {
        let messageVC = self.storyboard?.instantiateViewController(withIdentifier: "MessageVC") as! MessageViewController
        messageVC.conversationKey = roomKey
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
}
