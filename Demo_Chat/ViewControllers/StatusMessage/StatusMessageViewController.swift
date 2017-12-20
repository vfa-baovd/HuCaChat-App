//
//  StatusMessageViewController.swift
//  Demo_Chat
//
//  Created by HungNV on 5/3/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

class StatusMessageViewController: BaseViewController {

    @IBOutlet weak var tvStatusMessage: UITextView!
    @IBOutlet weak var lblPlanceholder: UILabel!
    var status_old: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsHelper.shared.setGoogleAnalytic(name: kGAIScreenName, value: "status_message_screen")
        AnalyticsHelper.shared.setFirebaseAnalytic(screenName: "status_message_screen", screenClass: classForCoder.description())
    }
    
    func setupView() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = Theme.shared.color_App()
        self.setupNavigation()
        tvStatusMessage.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapReceived(tap:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func setupData() {
        self.ref.child("Users").child(self.currentuserID).child("status").observeSingleEvent(of: .value, with: { (snap) in
            self.status_old = snap.value as? String ?? ""
            self.tvStatusMessage.text = self.status_old
            
            if self.status_old != "" {
                self.lblPlanceholder.isHidden = true
            } else {
                self.lblPlanceholder.isHidden = false
            }
        })
    }
    
    func setupNavigation() {
        setupNavigationBar(vc: self, title: Define.shared.getNameStatusMessageScreen().uppercased(), leftText: nil, leftImg: #imageLiteral(resourceName: "arrow_back"), leftSelector: #selector(self.actBack(btn:)), rightText: nil, rightImg: nil, rightSelector: nil, isDarkBackground: true, isTransparent: true)
    }
    
    func actBack(btn: UIButton) {
        if status_old != tvStatusMessage.text  {
            self.ref.child("Users").child(self.currentuserID).child("status").setValue(tvStatusMessage.text)
        }
        _ = navigationController?.popViewController(animated: true)
    }

    func tapReceived(tap: UITapGestureRecognizer) {
        if tvStatusMessage.isFirstResponder && tap.view != tvStatusMessage {
            tvStatusMessage.resignFirstResponder()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension StatusMessageViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        lblPlanceholder.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if tvStatusMessage.text.utf16.count < 1 {
            lblPlanceholder.isHidden = false
        }
    }
}
