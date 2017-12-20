//
//  LeftMenuViewController.swift
//  Demo_Chat
//
//  Created by Nguyen Van Hung on 2/5/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AssetsLibrary
import EZAlertController

class LeftMenuViewController: BaseViewController {
    @IBOutlet weak var btnAvatar: UIButton!
    @IBOutlet weak var lblDisplayName: UILabel!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var imgBG: UIImageView!
    
    var imagePicker:UIImagePickerController?
    var selectedImage:UIImage?
    var imgDataSelected:NSData?

    var user:UserModel! {
        didSet {
            self.lblDisplayName.text = user.display_name
            if let image = Helper.shared.getCachedImageForPath(fileName: "big_\(user.id).jpg") {
                DispatchQueue.main.async {
                    self.btnAvatar.setImage(image, for: .normal)
                    self.imgBG.image = image
                }
            } else {
                DispatchQueue.global(qos: .background).async { [weak self] () -> Void in
                    guard let strongSelf = self else {return }
                    
                    if let urlImage = URL(string: strongSelf.user.avatar_url) {
                        if let dataImg = try? Data(contentsOf: urlImage) {
                            if let img = UIImage(data: dataImg) {
                                DispatchQueue.main.async {
                                    strongSelf.btnAvatar.setImage(img, for: .normal)
                                    strongSelf.imgBG.image = img
                                    Helper.shared.cacheImageThumbnail(image: img, fileName: "big_\(strongSelf.user.id).jpg")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupData()
        self.clearAllNotice()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsHelper.shared.setGoogleAnalytic(name: kGAIScreenName, value: "left_screen")
        AnalyticsHelper.shared.setFirebaseAnalytic(screenName: "left_screen", screenClass: classForCoder.description())
        self.btnLogout.setTitle(NSLocalizedString("h_logout", "") , for: .normal)
    }
    
    func setupView() {
        self.view.backgroundColor = Theme.shared.color_App()
        
        setBorderButton(btn: btnAvatar, isCircle: true)
        setBorderButton(btn: btnLogout, isCircle: false)
    }
    
    func setupData() {
        // Lấy thông tin của tài khoản đang đăng nhập
        if let curUser = FIRAuth.auth()?.currentUser {
            self.ref.child("Users").child(curUser.uid).observeSingleEvent(of: .value , with: { (snap) in
                if !(snap.value is NSNull) {
                    if let data = snap.value as? [String:AnyObject] {
                        if let user = UserModel(uid: snap.key, jsonData: data) {
                            self.user = user
                        }
                    }
                }
            })
        }
        self.pleaseWait()
    }
    
    @IBAction func actChangeAvatar(_ sender: Any) {
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "home", action: "home_left_menu", label: "update_avatar", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "home", action: "home_left_menu", label: "update_avatar")
        
        self.showCamera()
    }

    @IBAction func actLogout(_ sender: Any) {
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "home", action: "home_left_menu", label: "logout", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "home", action: "home_left_menu", label: "logout")
        
        Helper.shared.removeUserDefault(key: kUserInfo)
        do {
            try FIRAuth.auth()?.signOut()
        } catch let signOutError as NSError {
            EZAlertController.alert(kAppName, message: signOutError.localizedDescription)
        }
        UIManager.shared.popAllViewControllerAndShowLoginViewController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension LeftMenuViewController {
    func showCamera() {
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        // Thiết bị có camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let openCamera = UIAlertAction(title: "Take a new photo", style: .default, handler: { (_) in
                
                AnalyticsHelper.shared.sendGoogleAnalytic(category: "home", action: "home_left_menu", label: "take_a_new_photo", value: nil)
                AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "home", action: "home_left_menu", label: "take_a_new_photo")
                
                self.imagePicker?.sourceType = .camera
                self.imagePicker?.isEditing = false
                self.present(self.imagePicker!, animated: true, completion: nil)
            })
            
            let openPhotoLibrary = UIAlertAction(title: "Choose from Library", style: .default, handler: { (_) in
                
                AnalyticsHelper.shared.sendGoogleAnalytic(category: "home", action: "home_left_menu", label: "choose_from_library", value: nil)
                AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "home", action: "home_left_menu", label: "choose_from_library")
                
                self.imagePicker?.sourceType = .photoLibrary
                self.imagePicker?.isEditing = false
                self.present(self.imagePicker!, animated: true, completion: nil)
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                
                AnalyticsHelper.shared.sendGoogleAnalytic(category: "home", action: "home_left_menu", label: "cancel", value: nil)
                AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "home", action: "home_left_menu", label: "cancel")
            })
            
            self.showAlertSheet(title: kAppName, msg: "", actions: [cancel,openPhotoLibrary,openCamera])
            
        } else {
            imagePicker?.sourceType = .photoLibrary
            imagePicker?.isEditing = false
            self.present(imagePicker!, animated: true, completion: nil)
        }
    }
}

extension LeftMenuViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
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
            self.startLoading()
            if let data = self.imgDataSelected as? Data {
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/jpeg"
                self.storageLocal.child("user").child("\(NSDate()).jpg").put(data, metadata: metadata, completion: { (dataUpload, error) in
                    
                    // Up hình lên storage bị lỗi
                    if let error = error {
                        EZAlertController.alert(kAppName, message: error.localizedDescription)
                        self.stopLoading()
                        self.imgDataSelected = nil
                        self.imagePicker = nil
                        return
                    }
                    
                    // Up hình thành công
                    if dataUpload != nil {
                        if let urlAvatar = dataUpload?.downloadURL()?.absoluteString {
                            if let currentUser:FIRUser = FIRAuth.auth()?.currentUser {
                                self.updateAvatarForUserModel(uid: currentUser.uid, urlAvatar: urlAvatar)
                            }
                        }
                        
                    }
                })
            }
        })
    }
    
    // Sau khi up hình thành công, cập nhật lại Url cho User
    func updateAvatarForUserModel(uid:String, urlAvatar: String ) {
        self.ref.child("Users").child(uid).updateChildValues(["avatar" : urlAvatar], withCompletionBlock: { (error, _) in
            if let error = error {
                EZAlertController.alert(kAppName, message: error.localizedDescription)
                self.stopLoading()
                self.imgDataSelected = nil
                self.imagePicker = nil
                return
            } else {
                self.user.avatar_url = urlAvatar
                self.appDelegate.currUser = self.user
                self.stopLoading()
                self.imgDataSelected = nil
                self.imagePicker = nil
            }
            
        })
    }
    
    // Người dùng không muốn đổi avatar nữa
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.imagePicker = nil
        self.dismiss(animated: true, completion: nil)
    }
}
