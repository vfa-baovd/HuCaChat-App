//
//  ForgotPasswordViewController.swift
//  HuCaChat
//
//  Created by HungNV on 9/6/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import Firebase
import EZAlertController

class ForgotPasswordViewController: BaseViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var btnOrLogin: UIButton!
    var gesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.enableSwipe = true
        setupView()
        setupGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsHelper.shared.setGoogleAnalytic(name: kGAIScreenName, value: "forgot_password_screen")
        AnalyticsHelper.shared.setFirebaseAnalytic(screenName: "forgot_password_screen", screenClass: classForCoder.description())
    }
    
    func setupView() {
        setAttributedForTextField(txt: txtEmail, placeholder: NSLocalizedString("h_email", ""), font: Theme.shared.font_primaryRegular(size: .small), delegate: self)
        
        setBorderButton(btn: btnForgotPassword, isCircle: false)
        setButtonFontBold(btn: btnForgotPassword, size: .medium)
        setButtonFontBold(btn: btnOrLogin, size: .small)
        btnForgotPassword.setTitle(NSLocalizedString("h_request_password", ""), for: .normal)
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
        gesture.isEnabled = false
    }
    
    @IBAction func actForgotPassword(_ sender: Any) {
        self.startLoading()
        let (isOK, message) = self.isValidInput()
        if isOK == false {
            EZAlertController.alert(kAppName, message: message)
            self.stopLoading()
            return;
        }
        
        FIRAuth.auth()?.sendPasswordReset(withEmail: txtEmail.text!, completion: { (error) in
            if let error = error {
                self.stopLoading()
                EZAlertController.alert(kAppName, message: error.localizedDescription)
            } else {
                self.stopLoading()
                EZAlertController.alert(kAppName, message: NSLocalizedString("h_request_password_sms", ""))
            }
        })
    }
    
    @IBAction func actOrLogin(_ sender: Any) {
        self.dismissViewController()
    }
    
    func isValidInput() -> (Bool, String) {
        let errNotInfo = NSLocalizedString("h_sms_full_info", "")
        let errWrongEmailFormat = NSLocalizedString("h_sms_right_email", "")
        
        guard let email = txtEmail.text else { return (false, errNotInfo) }
        if (email == "") {
            return (false, errNotInfo)
        }
        
        if !Helper.shared.isValidEmail(email: email) {
            return (false, errWrongEmailFormat)
        }
        
        return (true, "")
    }
}

extension ForgotPasswordViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        gesture.isEnabled = true
        
        if textField == self.txtEmail {
            AnalyticsHelper.shared.sendGoogleAnalytic(category: "user", action: "forgot_password", label: "input_email", value: nil)
            AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "user", action: "forgot_password", label: "input_email")
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
