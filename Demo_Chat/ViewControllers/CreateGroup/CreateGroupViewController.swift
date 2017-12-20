//
//  CreateGroupViewController.swift
//  Demo_Chat
//
//  Created by HungNV on 4/30/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import EZAlertController
import Firebase
import MobileCoreServices
import AssetsLibrary

class CreateGroupViewController: BaseViewController {
    @IBOutlet weak var txtNameGroup: UITextField!
    @IBOutlet weak var btnAddUsers: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnCreate: UIButton!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var lblUsers: UILabel!
    @IBOutlet weak var btnAvatar: UIButton!
    
    var usersSelected = Dictionary<String, String>()
    var gesture: UITapGestureRecognizer!
    var imagePicker:UIImagePickerController?
    var imgDataSelected:NSData? {
        didSet {
            DispatchQueue.main.async {
                if let imageData: Data = self.imgDataSelected as Data? {
                    self.btnAvatar.setImage(UIImage(data: imageData), for: .normal)
                } else {
                    self.btnAvatar.setImage(#imageLiteral(resourceName: "icon_default_group"), for: .normal)
                }
            }
        }
    }
    var photoDefault: String = "https://firebasestorage.googleapis.com/v0/b/appchat20170215.appspot.com/o/avatar_default_group.png?alt=media&token=d29357b0-4910-4d5c-8de7-660689b5d63c"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.enableSwipe = true
        self.setupView()
        self.setupGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tagListView.removeAllTags()
        for (_, name) in usersSelected {
            /*let index = id.index(id.startIndex, offsetBy: 3)
            let subID = id.substring(to: index)
            
            tagListView.addTag("\(name)-\(subID)")*/
            tagListView.addTag(name)
        }
        
        AnalyticsHelper.shared.setGoogleAnalytic(name: kGAIScreenName, value: "create_group_screen")
        AnalyticsHelper.shared.setFirebaseAnalytic(screenName: "create_group_screen", screenClass: classForCoder.description())
    }
    
    func setupView() {
        setupNavigation()
        
        self.setBorderButton(btn: btnAddUsers, isCircle: false)
        self.setBorderButton(btn: btnCancel)
        self.setBorderButton(btn: btnCreate)
        self.setBorderButton(btn: btnAvatar, isCircle: true)
        
        tagListView.delegate = self
        tagListView.textFont = UIFont.systemFont(ofSize: 14)
        self.btnCancel.setTitle(NSLocalizedString("h_cancel", ""), for: .normal)
        self.btnCreate.setTitle(NSLocalizedString("h_create", ""), for: .normal)
        self.txtNameGroup.placeholder = NSLocalizedString("h_group_name", "")
        self.lblUsers.text = NSLocalizedString("h_users", "")
    }
    
    func setupGesture() {
        gesture = UITapGestureRecognizer(target: self, action: #selector(self.tappedScreen))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        gesture.isEnabled = false
    }
    
    func tappedScreen() {
        txtNameGroup.resignFirstResponder()
        gesture.isEnabled = false
    }
    
    func setupNavigation() {
        setupNavigationBar(vc: self, title: Define.shared.getNameCreateGroupScreen().uppercased(), leftText: nil, leftImg: #imageLiteral(resourceName: "arrow_back"), leftSelector: #selector(self.actBack(btn:)), rightText: nil, rightImg: nil, rightSelector: nil, isDarkBackground: true, isTransparent: true)
    }
    
    func setBorderButton(btn: UIButton) {
        btn.layer.cornerRadius = btn.frame.size.height/2
        btn.layer.borderWidth = 1.0
        if btn.titleLabel?.text == "Cancel" {
            btn.layer.borderColor = Theme.shared.color_App().cgColor
            btn.backgroundColor = UIColor.white
        } else {
            btn.layer.borderColor = UIColor.white.cgColor
            btn.backgroundColor = Theme.shared.color_App()
        }
        btn.clipsToBounds = true
    }

    func actBack(btn: UIButton) {
        _ = navigationController?.popViewController(animated: true)
        
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "group", action: "create_group", label: "back", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "group", action: "create_group", label: "back")
    }
    
    @IBAction func actAddUsers(_ sender: Any) {
        let addUsersVC = self.storyboard?.instantiateViewController(withIdentifier: "AddUsersVC") as! AddUsersViewController
        addUsersVC.selected = usersSelected
        self.navigationController?.pushViewController(addUsersVC, animated: true)
        
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "group", action: "create_group", label: "add_user_to_group", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "group", action: "create_group", label: "add_user_to_group")
    }
    
    @IBAction func actChangeAvatar(_ sender: Any) {
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "group", action: "create_group", label: "input_avatar")
        
        self.showCamera()
    }
    
    @IBAction func actCancel(_ sender: Any) {
        if usersSelected.isEmpty || txtNameGroup.text == "" {
            EZAlertController.alert(kAppName, message: NSLocalizedString("h_sms_input_group", ""))
        } else {
            _ = navigationController?.popViewController(animated: true)
        }
        
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "group", action: "create_group", label: "cancel", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "group", action: "create_group", label: "cancel")
    }
    
    @IBAction func actCreate(_ sender: Any) {
        if usersSelected.isEmpty || txtNameGroup.text == "" {
            EZAlertController.alert(kAppName, message: NSLocalizedString("h_sms_input_group", ""))
            return
        }
        
        self.pleaseWait()
        
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "group", action: "create_group", label: "create", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "group", action: "create_group", label: "create")
        
        self.uploadAvatarToFirebase(completionHandler: { (value) in
            var photoStr = ""
            if value == "" {
                photoStr = self.photoDefault
            } else {
                photoStr = value
            }
            
            var people:[String:String] = [String:String]()
            for id in self.usersSelected.keys {
                people[self.ref.childByAutoId().key] = id
            }
            people[self.ref.childByAutoId().key] = self.currentuserID
            
            guard let currDisplayName = self.txtNameGroup.text else { return }
            
            let newRoomChatRef = self.ref.child("Conversations").childByAutoId()
            let conversationData = [
                "lastMessage": "",
                "lastTimeUpdated": NSDate().timeIntervalSince1970,
                "name": currDisplayName,
                "avatar": photoStr,
                "people": people
                ] as [String: Any]
            
            newRoomChatRef.setValue(conversationData) { (error, ref) in
                if error == nil {
                    var key: String
                    for id in self.usersSelected.keys {
                        key = self.ref.childByAutoId().key
                        self.ref.child("Users/\(id)/groups/\(key)").setValue(newRoomChatRef.key)
                    }
                    key = self.ref.childByAutoId().key
                    self.ref.child("Users/\(self.currentuserID)/groups/\(key)").setValue(newRoomChatRef.key)
                    self.pushToChatDetails(roomKey: newRoomChatRef.key)
                }
            }
        })
    }
    
    func pushToChatDetails(roomKey: String) {
        self.clearAllNotice()
        let groupVC = self.navigationController?.previousViewController() as! GroupViewController
        groupVC.isPushToMessageID = roomKey
        _ = navigationController?.popViewController(animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension CreateGroupViewController: TagListViewDelegate {
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        for (id, name) in usersSelected {
            /*let index = id.index(id.startIndex, offsetBy: 3)
            let subID = id.substring(to: index)*/
            
            if name == title {
                usersSelected.removeValue(forKey: id)
                sender.removeTagView(tagView)
                break
            }
        }
    }
}

extension CreateGroupViewController {
    func showCamera() {
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        // Thiết bị có camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let openCamera = UIAlertAction(title: NSLocalizedString("h_take_a_new_photo", ""), style: .default, handler: { (_) in
                
                AnalyticsHelper.shared.sendGoogleAnalytic(category: "group", action: "create_group", label: "take_a_new_photo", value: nil)
                AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "group", action: "create_group", label: "take_a_new_photo")
                
                self.imagePicker?.sourceType = .camera
                self.imagePicker?.isEditing = false
                self.present(self.imagePicker!, animated: true, completion: nil)
            })
            
            let openPhotoLibrary = UIAlertAction(title: NSLocalizedString("h_choose_from_library", ""), style: .default, handler: { (_) in
                
                AnalyticsHelper.shared.sendGoogleAnalytic(category: "group", action: "create_group", label: "choose_from_library", value: nil)
                AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "group", action: "create_group", label: "choose_from_library")
                
                self.imagePicker?.sourceType = .photoLibrary
                self.imagePicker?.isEditing = false
                self.present(self.imagePicker!, animated: true, completion: nil)
            })
            
            let cancel = UIAlertAction(title: NSLocalizedString("h_cancel", ""), style: .cancel, handler: { (_) in
                
                AnalyticsHelper.shared.sendGoogleAnalytic(category: "group", action: "create_group", label: "cancel", value: nil)
                AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "group", action: "create_group", label: "cancel")
            })
            
            self.showAlertSheet(title: kAppName, msg: NSLocalizedString("h_please_choose", ""), actions: [cancel,openPhotoLibrary,openCamera])
            
        } else {
            imagePicker?.sourceType = .photoLibrary
            imagePicker?.isEditing = false
            self.present(imagePicker!, animated: true, completion: nil)
        }
    }
}

extension CreateGroupViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // Xử lý sự kiện khi đã chọn hình
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            if mediaType == (kUTTypeImage as String) {
                
                if info[UIImagePickerControllerReferenceURL] != nil {
                    photoFromLibrary(info: info)
                } else {
                    photoFromCamera(info: info)
                }
            }
        }
    }
    
    // Người dụng chọn hình từ thư viện ảnh
    func photoFromLibrary(info: [String:AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let data = UIImageJPEGRepresentation(image, 0.07) {
                self.imgDataSelected = data as NSData?
                self.closePickerImageView()
            }
        }
    }
    
    // Người dùng chụp hình mới
    func photoFromCamera(info: [String:AnyObject]) {
        if let imgCap = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            // Save hình xuống thư viện
            ALAssetsLibrary().writeImage(toSavedPhotosAlbum: imgCap.cgImage, orientation: ALAssetOrientation(rawValue: imgCap.imageOrientation.rawValue)!,completionBlock:{ (path, error) -> Void in
                if error != nil {
                    self.dismiss(animated: true, completion: {
                        EZAlertController.alert(kAppName, message: NSLocalizedString("h_sms_update_avatar", ""))
                        self.stopLoading()
                        self.imgDataSelected = nil
                        self.imagePicker = nil
                    })
                }
                
                if path != nil {
                    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                        if let data = UIImageJPEGRepresentation(image, 0.07) {
                            self.imgDataSelected = data as NSData?
                            self.closePickerImageView()
                        }
                    }
                }
            })
        }
    }
    
    // Sau khi chọn hình, sẽ đóng chọn hình và bắt đầu đổi avatar
    func closePickerImageView() {
        self.dismiss(animated: true, completion: {
        })
    }
    
    func uploadAvatarToFirebase(completionHandler: @escaping(String) -> Void) {
        if let data = self.imgDataSelected as? Data {
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            self.storageLocal.child("group").child("\(NSDate()).jpg").put(data, metadata: metadata, completion: { (dataUpload, error) in
                
                // Up hình lên storage bị lỗi
                if let error = error {
                    EZAlertController.alert(kAppName, message: error.localizedDescription)
                    self.stopLoading()
                    self.imgDataSelected = nil
                    self.imagePicker = nil
                    completionHandler("")
                    return
                }
                
                // Up hình thành công
                if dataUpload != nil {
                    if let urlAvatar = dataUpload?.downloadURL()?.absoluteString {
                        completionHandler(urlAvatar)
                    }
                }
            })
        }
    }
    
    // Người dùng không muốn đổi avatar nữa
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.imagePicker = nil
        self.dismiss(animated: true, completion: nil)
    }
}

extension CreateGroupViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        gesture.isEnabled = true
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "group", action: "create_group", label: "input_group_name", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "group", action: "create_group", label: "input_group_name")
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
}

