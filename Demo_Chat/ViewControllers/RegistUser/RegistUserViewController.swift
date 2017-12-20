//
//  RegistUserViewController.swift
//  Demo_Chat
//
//  Created by Nguyen Van Hung on 2/12/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import Firebase
import EZAlertController
import NCMB
import MobileCoreServices
import AssetsLibrary

class RegistUserViewController: BaseViewController {
    
    @IBOutlet weak var btnAvatar: UIButton!
    @IBOutlet weak var txtDisplayName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnRequestAccess: UIButton!
    @IBOutlet weak var btnOrLogin: UIButton!
    
    var gesture: UITapGestureRecognizer!
    var imagePicker:UIImagePickerController?
    var imgDataSelected:NSData? {
        didSet {
            DispatchQueue.main.async {
                if let imageData: Data = self.imgDataSelected as Data? {
                    self.btnAvatar.setImage(UIImage(data: imageData), for: .normal)
                } else {
                    self.btnAvatar.setImage(#imageLiteral(resourceName: "avatar_defaulf"), for: .normal)
                }
            }
        }
    }
    
    var photoDefault: String = "https://firebasestorage.googleapis.com/v0/b/appchat20170215.appspot.com/o/avatar_default.png?alt=media&token=cb676261-389e-4fdf-9c9c-c06f3a6f1eb5"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.enableSwipe = true
        setupView()
        setupGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsHelper.shared.setGoogleAnalytic(name: kGAIScreenName, value: "request_access_screen")
        AnalyticsHelper.shared.setFirebaseAnalytic(screenName: "request_access_screen", screenClass: classForCoder.description())
    }
    
    func setupView() {
        setAttributedForTextField(txt: txtDisplayName, placeholder: NSLocalizedString("h_display_name", ""), font: Theme.shared.font_primaryRegular(size: .small), delegate: self)
        setAttributedForTextField(txt: txtEmail, placeholder: NSLocalizedString("h_email", ""), font: Theme.shared.font_primaryRegular(size: .small), delegate: self)
        setAttributedForTextField(txt: txtPassword, placeholder: NSLocalizedString("h_password", ""), font: Theme.shared.font_primaryRegular(size: .small), delegate: self)
        
        setBorderButton(btn: btnAvatar, isCircle: true)
        setBorderButton(btn: btnRequestAccess, isCircle: false)
        
        setButtonFontBold(btn: btnRequestAccess, size: .medium)
        setButtonFontBold(btn: btnOrLogin, size: .small)
        btnRequestAccess.setTitle(NSLocalizedString("h_request_accesss", ""), for: .normal)
        btnOrLogin.setTitle(NSLocalizedString("h_or_login", ""), for: .normal)
    }
    
    func setupGesture() {
        gesture = UITapGestureRecognizer(target: self, action: #selector(self.tappedScreen))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        gesture.isEnabled = false
    }
    
    func tappedScreen() {
        txtEmail.resignFirstResponder()
        txtPassword.resignFirstResponder()
        gesture.isEnabled = false
    }
    
    @IBAction func actChangeAvatar(_ sender: Any) {
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "user", action: "request_access", label: "input_avatar")
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "user", action: "request_access", label: "input_avatar", value: nil)
        
        self.showCamera()
    }
    
    @IBAction func actRequestAccess(_ sender: Any) {
        self.startLoading()
        let (isOK, message) = self.isValidInput()
        if isOK == false {
            EZAlertController.alert(kAppName, message: message)
            self.stopLoading()
            return;
        }
        
        FIRAuth.auth()?.createUser(withEmail: txtEmail.text!, password: txtPassword.text!, completion: { (user, error) in
            if let error = error {
                self.stopLoading()
                EZAlertController.alert(kAppName, message: error.localizedDescription)
            } else if let user = user {
                let updateUser = user.profileChangeRequest()
                updateUser.displayName = self.txtDisplayName.text
                
                self.uploadAvatarToFirebase(completionHandler: { (value) in
                    var photoStr = ""
                    if value == "" {
                        photoStr = self.photoDefault
                    } else {
                        photoStr = value
                    }
                    
                    if let photoURL:URL = URL(string: photoStr) {
                        updateUser.photoURL = photoURL
                        
                        Helper.shared.saveUserDefault(key: kUserInfo, value: ["user_id": user.uid , "email": self.txtEmail.text ?? "", "pass": self.txtPassword.text ?? ""])
                        
                        let currInstallation: NCMBInstallation = NCMBInstallation.current()
                        self.appDelegate.handleInstallation(currInstallation: currInstallation)
                        
                        self.addUserToDatabase(user: user, updateUser: updateUser, displayName: self.txtDisplayName.text!, email: self.txtEmail.text!, imgURLStr: photoURL.absoluteString)
                    }
                })
            }
        })
    }
    
    @IBAction func actOrLogin(_ sender: Any) {
        self.dismissViewController()
    }
    
    func isValidInput() -> (Bool, String) {
        let errNotInfo = NSLocalizedString("h_sms_full_info", "")
        let errWrongEmailFormat = NSLocalizedString("h_sms_right_email", "")
        
        guard let displyName = txtDisplayName.text else { return (false, errNotInfo) }
        
        guard let email = txtEmail.text else { return (false, errNotInfo) }
        
        guard let pass = txtPassword.text else { return (false, errNotInfo) }
        
        if (displyName == "" || email == "" || pass == "") {
            return (false, errNotInfo)
        }
        
        if !Helper.shared.isValidEmail(email: email) {
            return (false, errWrongEmailFormat)
        }
        
        return (true, "")
    }
    
    func addUserToDatabase(user: FIRUser, updateUser: FIRUserProfileChangeRequest, displayName: String, email: String, imgURLStr: String) {
        updateUser.commitChanges { (error) in
            if let error = error {
                self.stopLoading()
                EZAlertController.alert(kAppName, message: error.localizedDescription)
            } else {
                let time_interval = "\(NSDate().timeIntervalSince1970)"
                let userInfo: [String:Any] = [
                    "display_name": displayName,
                    "email": email,
                    "avatar": imgURLStr,
                    "time_interval": time_interval,
                    "provider": user.providerID,
                    "status": "",
                    "login_date": time_interval,
                    "is_online": "Available"
                ]
                self.addUserInfo(user: user, userInfo: userInfo, isDismiss: true)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension RegistUserViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        gesture.isEnabled = true
        
        switch textField {
        case self.txtDisplayName:
            AnalyticsHelper.shared.sendGoogleAnalytic(category: "user", action: "request_access", label: "input_display_name", value: nil)
            AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "user", action: "request_access", label: "input_display_name")
            break
            
        case self.txtEmail:
            AnalyticsHelper.shared.sendGoogleAnalytic(category: "user", action: "request_access", label: "input_email", value: nil)
            AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "user", action: "request_access", label: "input_email")
            break
            
        default:
            AnalyticsHelper.shared.sendGoogleAnalytic(category: "user", action: "request_access", label: "input_password", value: nil)
            AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "user", action: "request_access", label: "input_password")
            break
        }
        
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

extension RegistUserViewController {
    func showCamera() {
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        // Thiết bị có camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let openCamera = UIAlertAction(title: NSLocalizedString("h_take_a_new_photo", ""), style: .default, handler: { (_) in
                
                AnalyticsHelper.shared.sendGoogleAnalytic(category: "user", action: "request_access", label: "take_a_new_photo", value: nil)
                AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "user", action: "request_access", label: "take_a_new_photo")
                
                self.imagePicker?.sourceType = .camera
                self.imagePicker?.isEditing = false
                self.present(self.imagePicker!, animated: true, completion: nil)
            })
            
            let openPhotoLibrary = UIAlertAction(title: NSLocalizedString("h_choose_from_library", ""), style: .default, handler: { (_) in
                
                AnalyticsHelper.shared.sendGoogleAnalytic(category: "user", action: "request_access", label: "choose_from_library", value: nil)
                AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "user", action: "request_access", label: "choose_from_library")
                
                self.imagePicker?.sourceType = .photoLibrary
                self.imagePicker?.isEditing = false
                self.present(self.imagePicker!, animated: true, completion: nil)
            })
            
            let cancel = UIAlertAction(title: NSLocalizedString("h_cancel", ""), style: .cancel, handler: { (_) in
                
                AnalyticsHelper.shared.sendGoogleAnalytic(category: "user", action: "request_access", label: "cancel", value: nil)
                AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "user", action: "request_access", label: "cancel")
            })
            
            self.showAlertSheet(title: kAppName, msg: NSLocalizedString("h_please_choose", ""), actions: [cancel,openPhotoLibrary,openCamera])
            
        } else {
            imagePicker?.sourceType = .photoLibrary
            imagePicker?.isEditing = false
            self.present(imagePicker!, animated: true, completion: nil)
        }
    }
}

extension RegistUserViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
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
            self.storageLocal.child("user").child("\(NSDate()).jpg").put(data, metadata: metadata, completion: { (dataUpload, error) in
                
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
