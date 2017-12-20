//
//  MessageViewController.swift
//  Demo_Chat
//
//  Created by Nguyen Van Hung on 3/1/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import Firebase
import AssetsLibrary
import MobileCoreServices
import EZAlertController

class MessageViewController: BaseViewController {
    
    @IBOutlet weak var tvInputMessage: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var vInputSendMessage: UIView!
    @IBOutlet weak var cstInputSendMessageOffsetBottom: NSLayoutConstraint!
    
    @IBOutlet weak var cstTVMessageOffsetHeight: NSLayoutConstraint!
    lazy var downloadPhotoQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Download photo"
        queue.maxConcurrentOperationCount = 2
        
        return queue
    }()
    
    var conversationKey:String = Define.shared.getGeneralChannelKey()
    var messages: [Message] = [Message]()
    var downloadingTasks = Dictionary <String, Operation>()
    var isFirstLoad = true
    var isLoadingData = false
    var hasNextData = true
    var strPlaceHolder = NSLocalizedString("h_say_something", "")
    var hideKeyboardTap: UITapGestureRecognizer!
    var keyboardPresenting = false
    let refreshControl = UIRefreshControl()
    var lastMessageKey: String?
    var userAvtDict = Dictionary <String, String>()
    var receive_user = [String]()
    var imgPickerVC: UIImagePickerController?
    var flagLongPressGesture = 0
    var kReceiverId: String?
    var receiverUser: UserModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.enableSwipe = true
//        self.startLoading()
        setupView()
        createNotificationCenter()
        hideKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(tapScreen))
        messageChannel = self.ref.child("Conversations/\(conversationKey)/messages")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsHelper.shared.setGoogleAnalytic(name: kGAIScreenName, value: "message_screen")
        AnalyticsHelper.shared.setFirebaseAnalytic(screenName: "message_screen", screenClass: classForCoder.description())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFirstLoad {
            isFirstLoad = false
            fetchConversationName()
            loadData(lastKey: nil)
            listenUserDidJoinConversationFromFirebase()
            listenMessageDidAddFromFirebase()
            listenMessageDidRemoveFromFirebase()
        }
    }
    
    func setupView() {
        setupNavigation()
        setupInputMessage()
        setupTable()
        self.btnSend.isEnabled = false
    }
    
    func setupInputMessage() {
        tvInputMessage.layer.cornerRadius = 5.0
        tvInputMessage.layer.borderWidth = 0.5
        tvInputMessage.layer.borderColor = Theme.shared.color_App().cgColor
        tvInputMessage.clipsToBounds = true
        tvInputMessage.text = strPlaceHolder
        tvInputMessage.textColor = Theme.shared.color_App()
    }
    
    func setupNavigation() {
        setupNavigationBar(vc: self, title: "...", leftText: nil, leftImg: #imageLiteral(resourceName: "arrow_back"), leftSelector: #selector(self.actBack(btn:)), rightText: nil, rightImg: #imageLiteral(resourceName: "icon_warning"), rightSelector: #selector(self.actWarning(btn:)), isDarkBackground: true, isTransparent: true)
    }
    
    func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.allowsMultipleSelection = false
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.addSubview(refreshControl)
    }
    
    func fetchConversationName() {
        self.ref.child("Conversations/\(conversationKey)/name").observeSingleEvent(of: .value, with: { (snap) in
            if let generalName = snap.value as? String {
                self.changeTitle(title: generalName)
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: nil, style: .plain, target: nil, action: nil)
            } else if let privateNameDict = snap.value as? [String:String] {
                if let privateName = privateNameDict[self.currentuserID] {
                    self.changeTitle(title: privateName)
                }
            }
        })
    }
    
    func loadData(lastKey: String?) {
        if isLoadingData || !hasNextData {
            return
        }
        
        isLoadingData = true
        var dbRef: FIRDatabaseQuery!
        if let lastMessageKey = lastKey {
            dbRef = messageChannel.queryOrderedByKey().queryEnding(atValue: lastMessageKey).queryLimited(toLast: NUM_LIMIT + 1)
        } else {
            dbRef = messageChannel.queryOrderedByKey().queryLimited(toLast: NUM_LIMIT)
        }
        
        dbRef.observeSingleEvent(of: .value, with: { (snap) in
            if let items = self.parseData(snap: snap) {
                self.refreshControl.endRefreshing()
                self.hasNextData = UInt(items.count) == NUM_LIMIT
                
                if self.lastMessageKey == nil {
                    self.messages = items
                    self.tableView.reloadData()
                    self.scrollTableViewToEnd()
                } else {
                    self.messages = items + self.messages
                    self.tableView.reloadData()
                }
                
                self.lastMessageKey = self.getLastMessageKey()
            } else {
                self.hasNextData = false
            }
            
//            self.stopLoading()
            self.isLoadingData = false
        })
    }
    
    func parseData(snap: FIRDataSnapshot) -> [Message]? {
        if snap.children.allObjects.count == 0 {
            return nil
        }
        
        var result = [Message]()
        
        for messageObj in snap.children.allObjects {
            guard let messageSnap = messageObj as? FIRDataSnapshot else { continue }
            guard let messageInfo = messageSnap.value as? [String:AnyObject] else { continue }
            
            if self.lastMessageKey == messageSnap.key {
                continue
            }
            
            if let message = Message(message_id: messageSnap.key, message_info: messageInfo) {
                result.append(message)
            }
        }
        
        return result
    }
    
    func getLastMessageKey() -> String? {
        guard let firstMessage = self.messages.first else { return nil }
        
        return firstMessage.message_id
    }
    
    func listenUserDidJoinConversationFromFirebase() {
        self.ref.child("Conversations").child(conversationKey).child("people").observe(.childAdded, with: { (snap) in
            guard let userID = snap.value as? String else { return }
            
            if userID != self.currentuserID {
                self.receive_user.append(userID)
            }
            
            self.ref.child("Users").child(userID).observeSingleEvent(of: .value, with: { (userSnap) in
                guard let userDict = userSnap.value as? [String:AnyObject] else { return }
                if let avatar = userDict["avatar"] as? String {
                    self.userAvtDict[userSnap.key] = avatar
                }
            })
        })
    }
    
    func listenMessageDidAddFromFirebase() {
        messageChannel.queryLimited(toLast: 1).observe(.childAdded, with: { (snap) in
            for msg in self.messages {
                if msg.message_id == snap.key {
                    return
                }
            }
            
            guard let messageInfo = snap.value as? [String:AnyObject] else { return }
            
            if let message = Message(message_id: snap.key, message_info: messageInfo) {
                self.messages.append(message)
                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .none)
                self.scrollTableViewToEnd()
            }
        })
    }
    
    func listenMessageDidRemoveFromFirebase() {
        self.messageChannel.observe(.childRemoved, with: { (snap) in
            if !(snap.value is NSNull) {
                if self.messages.count > 0 {
                    let uid = snap.key
                    var msgIndexDeleted:Int?
                    for i in 0..<self.messages.count {
                        let msgRemoved: Message = self.messages[i]
                        if uid == msgRemoved.message_id {
                            msgIndexDeleted = i
                            break
                        }
                    }
                    
                    guard let i = msgIndexDeleted else { return }
                    self.messages.remove(at: i)
                    let indexPath = IndexPath(row: i, section: 0)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        })
    }
    
    // MARK:- Action method
    func actBack(btn: UIButton) {
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "home_and_group", action: "chat", label: "back", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "home_and_group", action: "chat", label: "back")
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    func actWarning(btn: UIButton) {
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "home_and_group", action: "chat", label: "warning", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "home_and_group", action: "chat", label: "warning")
        if let user = self.receiverUser {
            EZAlertController.alert(kAppName, message: "\(NSLocalizedString("h_sms_block_user", "")) \(user.display_name)", buttons: [NSLocalizedString("h_cancel", ""), NSLocalizedString("h_block", "")]) { (alertAction, position) -> Void in
                if position == 0 {
                    #if CHAT_DEV
                        print("Cancel")
                    #endif
                    
                    AnalyticsHelper.shared.sendGoogleAnalytic(category: "home_and_group", action: "chat", label: "cancel_block", value: nil)
                    AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "home_and_group", action: "chat", label: "cancel_block")
                } else if position == 1 {
                    if let user = self.receiverUser {
                        self.updateBlockUser(blockID: user.id)
                        AnalyticsHelper.shared.sendGoogleAnalytic(category: "home_and_group", action: "chat", label: "touch_block", value: nil)
                        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "home_and_group", action: "chat", label: "touch_block")
                    }
                    
                }
            }
        }
    }
    
    func updateBlockUser(blockID: String) {
        self.ref.child("Users").child(self.currentuserID).child("block_users").observeSingleEvent(of: .value, with: { (snap) in
            var isExist = false
            if let userArr = snap.value as? [String:String] {
                for userSnap in userArr {
                    if userSnap.value == blockID {
                        isExist = true
                        break
                    }
                }
            }
            
            if !isExist {
                let key = self.ref.childByAutoId().key
                self.ref.child("Users/\(self.currentuserID)/block_users/\(key)").setValue(blockID)
                self.getCurrentUser()
            }
            _ = self.navigationController?.popViewController(animated: true)
        })
    }
    
    @IBAction func actSend(_ sender: Any) {
        if(self.tvInputMessage.text == strPlaceHolder || self.tvInputMessage.text == "") {
            return
        }
        
        let content = self.tvInputMessage.text!
        self.sendMessageToFirebase(type: .Text, content: content, img_width: 0, img_height: 0, img_name: "")
        
        self.tvInputMessage.text = ""
        self.cstTVMessageOffsetHeight.constant = 35
        
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "home_and_group", action: "chat", label: "send_message", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "home_and_group", action: "chat", label: "send_message")
    }
    
    @IBAction func actAttach(_ sender: Any) {
        showAlertPhoto()
        
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "home_and_group", action: "chat", label: "choose_image", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "home_and_group", action: "chat", label: "choose_image")
    }
    
    func sendMessageToFirebase(type: MessageType, content: String, img_width: Int, img_height: Int, img_name: String) {
        let create_date = NSDate().timeIntervalSince1970
        let newMsgRef = self.messageChannel.childByAutoId()
        
        var message_type = "text"
        if type == .Photo {
            message_type = "photo"
        }
        
        let messageInfo:[String:AnyObject] = [
            "content": content as AnyObject,
            "message_type": message_type as AnyObject,
            "create_date": create_date as AnyObject,
            "sender_id": self.currentuserID as AnyObject,
            "img_width": img_width as AnyObject,
            "img_height": img_height as AnyObject,
            "img_name": img_name as AnyObject
        ]
        newMsgRef.setValue(messageInfo)
        
        let lastMsg = (type == .Text) ? content : "Photo message"
        self.ref.child("Conversations/\(conversationKey)/lastMessage").setValue(lastMsg)
        self.ref.child("Conversations/\(conversationKey)/lastTimeUpdate").setValue(create_date)
        
        PushHelper.shared.pushHistory(receive_user: receive_user, send_id: self.currentuserID, room_id: conversationKey, message_id: newMsgRef.key, push_type: TYPE_PUSH_CHAT, message_content: content) { (error) in
            if error != nil {
                #if DEBUG
                    print("[Push] - \(String(describing: error?.localizedDescription))")
                #endif
            } else {
                #if DEBUG
                    print("[Push] - OK")
                #endif
            }
        }
    }
    
    func showAlertPhoto() {
        imgPickerVC = UIImagePickerController()
        imgPickerVC?.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let openCamera = UIAlertAction(title: NSLocalizedString("h_take_a_new_photo", ""), style: .default, handler: { (_) in
                
                AnalyticsHelper.shared.sendGoogleAnalytic(category: "home_and_group", action: "chat", label: "take_a_new_photo", value: nil)
                AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "home_and_group", action: "chat", label: "take_a_new_photo")
                
                self.imgPickerVC?.sourceType = .camera
                self.imgPickerVC?.isEditing = true
                self.present(self.imgPickerVC!, animated: true, completion: nil)
            })
            
            let openPhotoLibrary = UIAlertAction(title: NSLocalizedString("h_choose_from_library", ""), style: .default, handler: { (_) in
                
                AnalyticsHelper.shared.sendGoogleAnalytic(category: "home_and_group", action: "chat", label: "choose_from_library", value: nil)
                AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "home_and_group", action: "chat", label: "choose_from_library")
                
                self.imgPickerVC?.sourceType = .photoLibrary
                self.imgPickerVC?.isEditing = true
                self.imgPickerVC?.allowsEditing = true
                self.present(self.imgPickerVC!, animated: true, completion: nil)
            })
            
            let cancel = UIAlertAction(title: NSLocalizedString("h_cancel", ""), style: .cancel, handler: { (_) in
                
                AnalyticsHelper.shared.sendGoogleAnalytic(category: "home_and_group", action: "chat", label: "cancel", value: nil)
                AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "home_and_group", action: "chat", label: "cancel")
            })
            self.showAlertSheet(title: kAppName, msg: NSLocalizedString("h_please_choose", ""), actions: [cancel, openPhotoLibrary, openCamera])
        } else {
            imgPickerVC?.sourceType = .photoLibrary
            imgPickerVC?.isEditing = true
            imgPickerVC?.allowsEditing = true
            self.present(imgPickerVC!, animated: true, completion: nil)
        }
    }
    
    // MARK:- Keyboard
    override func handleKeyboardWillShow(duration: TimeInterval, keyBoardRect: CGRect) {
        self.view.addGestureRecognizer(hideKeyboardTap)
        keyBoardChatDetailControl(flagKeyboard: 0, duration: duration, keyBoardRect: keyBoardRect)
    }
    
    override func handleKeyboardWillHide(duration: TimeInterval, keyBoardRect: CGRect) {
        self.view.removeGestureRecognizer (hideKeyboardTap)
        keyBoardChatDetailControl(flagKeyboard: 1, duration: duration, keyBoardRect: keyBoardRect)
    }
    
    func keyBoardChatDetailControl(flagKeyboard: Int, duration: TimeInterval, keyBoardRect: CGRect) {
        var keyboardHeight: CGFloat = 0
        keyboardHeight = 0
        
        let tabbarHeight:CGFloat = tabBarController?.tabBar.bounds.size.height ?? 0
        
        if flagKeyboard == 0 {
            keyboardHeight = (keyBoardRect.height - tabbarHeight)
        }
        
        self.keyboardPresenting = flagKeyboard == 0
        
        UIView.animate(withDuration: duration, animations: {
            self.cstInputSendMessageOffsetBottom.constant = keyboardHeight
            self.tvInputMessage.superview?.layoutIfNeeded()
            
            self.tableView.contentInset.bottom = (flagKeyboard == 0) ? keyBoardRect.height + 22.5  : 22.5
        }) { (Bool) in
            self.scrollTableViewToEnd()
        }
    }
    
    func scrollTableViewToEnd() {
        let rowIndex = self.messages.count > 0 ? self.messages.count - 1 : 0
        if rowIndex == 0 {
            return
        }
        let lastIndexPath = IndexPath(row: rowIndex, section: 0)
        self.tableView.scrollToRow(at: lastIndexPath, at: .none , animated: false)
    }
    
    deinit {
//        self.stopLoading()
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK:- UITableViewDelegate
extension MessageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        
        var cellId = (message.sender_id == currentuserID) ? "cell_sender" : "cell_receiver"
        let borderColor = (message.sender_id == currentuserID) ? Theme.shared.color_Online() : Theme.shared.color_App()
        
        if message.message_type == .Photo {
            cellId += "_photo"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatCell
        cell.message = message
        cell.imgAvatar.layer.borderColor = borderColor.cgColor
        cell.delegateChat = self
        
        if let avatar = self.userAvtDict[message.sender_id] {
            if let downloadedAvt = Helper.shared.getCachedImageForPath(fileName: "\(message.sender_id).jpg") {
                cell.imgAvatar.image = downloadedAvt
            } else {
                if !tableView.isDecelerating {
                    let downloader = MessageDownPhotoOperation(indexPath: indexPath, photoURL: avatar, photoPosition: .avatar, delegate: self)
                    startDownloadImage(downloader: downloader)
                }
            }
        }
        
        if message.message_type == .Text {
            let textChatCell = cell as! TextChatCell
            textChatCell.setcontent()
        } else {
            let photoChatCell = cell as! PhotoChatCell
            photoChatCell.delegate = self
            
            let newHeight = CGFloat(200 * message.img_height / message.img_width)
            photoChatCell.cstImgMessageOffsetHeight.constant = newHeight
            photoChatCell.cstImgMessageOffsetWidth.constant = 200
            
            photoChatCell.imgMessage.image = nil
            let img_url = message.content
            
            let url = URL(string: img_url)
            if let strURL = url?.lastPathComponent {
                if let downloadedImg = Helper.shared.getCachedImageForPath(fileName: strURL) {
                    photoChatCell.imgMessage.image = downloadedImg
                } else {
                    if !tableView.isDecelerating {
                        let downloader = MessageDownPhotoOperation(indexPath: indexPath, photoURL: img_url, photoPosition: .message, delegate: self)
                        startDownloadImage(downloader: downloader)
                    }
                }
            }
        }
        
        return cell
    }
    
    func startDownloadImage(downloader: MessageDownPhotoOperation) {
        let trackKey = downloader.photoPosition == .avatar ? "avatar\(downloader.indexPath)" : "\(downloader.indexPath)"
        
        if let _ = downloadingTasks[trackKey] {
            return
        }
        
        downloadingTasks[trackKey] = downloader
        downloadPhotoQueue.addOperation(downloader)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView is UITableView else { return } //scroll cua textview thi return
        
        if scrollView.isDecelerating {
            downloadPhotoQueue.cancelAllOperations()
            downloadingTasks.removeAll()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView is UITableView else { return } //scroll cua textview thi return
        
        if refreshControl.isRefreshing {
            if hasNextData {
                loadData(lastKey: lastMessageKey)
                
                AnalyticsHelper.shared.sendGoogleAnalytic(category: "home_and_group", action: "chat", label: "load_more_message", value: nil)
                AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "home_and_group", action: "chat", label: "load_more_message")
            } else {
                refreshControl.endRefreshing()
            }
        }
        
        if !keyboardPresenting {
            tableView.reloadData()
        }
    }
}

// MARK:- PhotoChatCellDelegate
extension MessageViewController: PhotoChatCellDelegate {
    func tappedMessageTypePhoto(cell: PhotoChatCell, tap: UITapGestureRecognizer) {
        if let message = cell.message {
            self.clearAllNotice()
            let detailImageVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailImageVC") as! DetailImageViewController
            detailImageVC.url = message.content
            self.navigationController?.pushViewController(detailImageVC, animated: true)
        }
        
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "chat_and_group", action: "chat", label: "detail_image", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "chat_and_group", action: "chat", label: "detail_image")
    }
}

// MARK:- ChatCellDelegate
extension MessageViewController: ChatCellDelegate {
    func longPressOnMessage(cell: ChatCell, longPress: UILongPressGestureRecognizer, message: Message) {
        if longPress.state != UIGestureRecognizerState.ended {
            if self.flagLongPressGesture == 0 {
                self.flagLongPressGesture = 1
                if message.sender_id != self.currentuserID {
                    return
                }
                
                EZAlertController.alert(kAppName, message: "\(NSLocalizedString("h_confirm_delete_message", ""))", buttons: [NSLocalizedString("h_cancel", ""), NSLocalizedString("h_delete", "")]) { (alertAction, position) -> Void in
                    if position == 0 {
                        #if CHAT_DEV
                            print("Cancel")
                        #endif
                        
                        AnalyticsHelper.shared.sendGoogleAnalytic(category: "chat_and_group", action: "delete_message", label: "touch_cancel", value: nil)
                        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "chat_and_group", action: "delete_message", label: "touch_cancel")
                    } else if position == 1 {
                        if message.message_type == .Photo {
                            if let img_name = message.img_name {
                                let desertRef = self.storageLocal.child("message").child(self.conversationKey).child(img_name)
                                desertRef.delete(completion: { (error) in
                                    if error != nil {
                                        #if CHAT_DEV
                                            print("Delete file error")
                                        #endif
                                    }
                                })
                            }
                        }
                        self.messageChannel.child(message.message_id).removeValue()
                        
                        AnalyticsHelper.shared.sendGoogleAnalytic(category: "chat_and_group", action: "delete_message", label: "touch_delete", value: nil)
                        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "chat_and_group", action: "delete_message", label: "touch_delete")
                    }
                }
            }
        } else {
            self.flagLongPressGesture = 0
        }
    }
}

// MARK:- UITextViewDelegate
extension MessageViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == tvInputMessage {
            if(self.tvInputMessage.text == strPlaceHolder) {
                self.tvInputMessage.text = ""
                self.tvInputMessage.textColor = Theme.shared.color_App()
            }
        }
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.text == "" && textView == tvInputMessage) {
            textView.text = strPlaceHolder
            textView.textColor = Theme.shared.color_App()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.btnSend.isEnabled = !textView.text.isEmpty
        let fixedWidth = textView.bounds.size.width - 15
        let fixedHeight:CGFloat = 35
        let msgContent = textView.text
        let newSize = NSString(string: msgContent!).boundingRect(
            with        : CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)),
            options     : [.usesLineFragmentOrigin, .usesFontLeading],
            attributes  : [NSFontAttributeName : textView.font!],
            context     : nil)
        let newTVHeight = max(newSize.size.height + 15, fixedHeight)
        cstTVMessageOffsetHeight.constant = newTVHeight
        self.tvInputMessage.superview?.layoutIfNeeded()
    }
}

// MARK:- DownloadPhotoOperationDelegate
extension MessageViewController: DownloadPhotoOperationDelegate {
    func downloadPhotoDidFail(operation: DownloadPhotoOperation) {
        #if DEBUG
            print("Download faile")
        #endif
    }
    
    func downloadPhotoDidFinish(operation: DownloadPhotoOperation, image: UIImage) {
        let message = self.messages[operation.indexPath.row]
        let msgDownPhotoOperation = operation as! MessageDownPhotoOperation
        
        if msgDownPhotoOperation.photoPosition == .avatar {
            let size = CGSize(width: 40, height: 40)
            let resultImg = image.scaleImage(size: size).createRadius(size: size, radius: size.width/2, byRoundingCorners: UIRectCorner.allCorners)
            Helper.shared.cacheImageThumbnail(image: resultImg, fileName: "\(message.sender_id).jpg")
            self.tableView.reloadRows(at: [operation.indexPath], with: .automatic)
            downloadingTasks.removeValue(forKey: "avatar\(operation.indexPath)")
            return
        }
        
        if (message.img_height != 0 || message.img_width != 0) {
            let newHeight = CGFloat(200 * message.img_height / message.img_width)
            let size = CGSize(width: 200, height: newHeight)
            let img_result = image.scaleImage(size: size)
            
            let url = URL(string: msgDownPhotoOperation.photoURL)
            if let strURL = url?.lastPathComponent {
                Helper.shared.cacheImageThumbnail(image: img_result, fileName: strURL)
            }
            self.tableView.reloadRows(at: [operation.indexPath], with: .automatic)
            downloadingTasks.removeValue(forKey: "\(operation.indexPath)")
        }
    }
}

// MARK:- UIImagePickerControllerDelegate
extension MessageViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            if mediaType == (kUTTypeImage as String) {
                if let imageUrl  = info[UIImagePickerControllerReferenceURL] as? NSURL {
                    if imageUrl.path != nil {
                        self.getImageFromPhotoLibrary(info: info)
                    }
                } else {
                    getImageFromTakePhoto(info: info)
                }
            }
        }
    }
    
    func getImageFromPhotoLibrary(info: [String:AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.uploadImgToFirebase(img: image)
        }
    }
    
    func getImageFromTakePhoto(info: [String:AnyObject]) {
        if let imgCap = info[UIImagePickerControllerOriginalImage] as? UIImage {
            ALAssetsLibrary().writeImage(toSavedPhotosAlbum: imgCap.cgImage, orientation: ALAssetOrientation(rawValue: imgCap.imageOrientation.rawValue)!,completionBlock:{ (path, error) -> Void in
                if path != nil  {
                    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                        self.uploadImgToFirebase(img: image)
                    }
                }
            })
        }
    }
    
    /// Handle image to upload to Firebase
    func uploadImgToFirebase(img: UIImage) {
        let imgWidth = Int(img.size.width)
        let imgHeight = Int(img.size.height)
        
        if let data = UIImageJPEGRepresentation(img, 0.07) {
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            let imgName = "\(NSDate()).jpg"
            self.storageLocal.child("message").child(conversationKey).child(imgName).put(data, metadata: metadata, completion: { (dataUpload, error) in
                if dataUpload != nil {
                    if let content = dataUpload?.downloadURL()?.absoluteString {
                        self.sendMessageToFirebase(type: .Photo, content: content, img_width: imgWidth, img_height: imgHeight, img_name: imgName)
                    }
                }
            })
        }
        
        imgPickerVC?.dismiss(animated: true, completion: nil)
    }
    
    func showAlertSavedImage() {
        let alert = UIAlertController(title: "Message", message: "Your photo was saved to Camera Roll", preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(actionOK)
        self.present(alert, animated: true, completion: nil)
    }
}
