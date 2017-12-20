//
//  ContactViewController.swift
//  Demo_Chat
//
//  Created by Nguyen Van Hung on 2/26/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import Firebase

class ContactViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var downloadPhotoQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Download avatar contact"
        queue.maxConcurrentOperationCount = 2
        
        return queue
    }()
    var users: [UserModel] = [UserModel]()
    var downloadingTasks = Dictionary <IndexPath, Operation>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startLoading()
        setupView()
        listenUpdateFromFirebase()
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
        setupNavigationBar(vc: self, title: Define.shared.getNameContactScreen().uppercased(), leftText: nil, leftImg: #imageLiteral(resourceName: "arrow_back"), leftSelector: #selector(self.actBack(btn:)), rightText: nil, rightImg: nil, rightSelector: nil, isDarkBackground: true, isTransparent: true)
    }
    
    func actBack(btn: UIButton) {
        _ = navigationController?.popViewController(animated: true)
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

extension ContactViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath) as! ContactCell
        
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
        
        return cell
    }
}

extension ContactViewController: UITableViewDelegate {
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

extension ContactViewController: DownloadPhotoOperationDelegate {
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

extension ContactViewController: ContactCellDelegate {
    func tappedContentView(myIndex: IndexPath) {
        let selectedUser = self.users[myIndex.row]
        self.pleaseWait()
        
        self.ref.child("Users").child(selectedUser.id).observeSingleEvent(of: .value, with: { (snap) in
            guard let userDict = snap.value as? [String:AnyObject] else { return }
            
            if let user = UserModel(uid: selectedUser.id, jsonData: userDict) {
                if let roomKey = user.conversations?[self.currentuserID] {
                    self.pushToChatDetails(roomKey: roomKey)
                } else {
                    self.createConversationWith(user: user)
                }
            }
        })
    }
    
    func pushToChatDetails(roomKey: String) {
        self.clearAllNotice()
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
                self.pushToChatDetails(roomKey: newRoomChatRef.key)
            }
        }
    }
}
