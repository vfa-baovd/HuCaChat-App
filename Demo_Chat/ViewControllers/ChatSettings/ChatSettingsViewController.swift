//
//  ChatSettingsViewController.swift
//  Demo_Chat
//
//  Created by HungNV on 5/4/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import Firebase

class ChatSettingsViewController: BaseViewController {
    @IBOutlet weak var lblReadReceipt: UILabel!
    @IBOutlet weak var lblLastSeen: UILabel!
    @IBOutlet weak var lblDescriptionReadReceipt: UILabel!
    @IBOutlet weak var lblDescriptionLastSeen: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.enableSwipe = true
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsHelper.shared.setGoogleAnalytic(name: kGAIScreenName, value: "chat_settings_screen")
        AnalyticsHelper.shared.setFirebaseAnalytic(screenName: "chat_settings_screen", screenClass: classForCoder.description())
    }
    
    func setupView() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = Theme.shared.color_App()
        self.setupNavigation()
        self.lblReadReceipt.text = NSLocalizedString("h_read_receipt", "")
        self.lblLastSeen.text = NSLocalizedString("h_last_seen", "")
        self.lblDescriptionReadReceipt.text = NSLocalizedString("h_description_read_receipt", "")
        self.lblDescriptionLastSeen.text = NSLocalizedString("h_description_last_seen", "")
    }
    
    func setupNavigation() {
        setupNavigationBar(vc: self, title: Define.shared.getNameChatSettingsScreen().uppercased(), leftText: nil, leftImg: #imageLiteral(resourceName: "arrow_back"), leftSelector: #selector(self.actBack(btn:)), rightText: nil, rightImg: nil, rightSelector: nil, isDarkBackground: true, isTransparent: true)
    }
    
    func actBack(btn: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changeReadReceipt(_ sender: UISwitch) {
        if sender.isOn {
            AnalyticsHelper.shared.sendGoogleAnalytic(category: "more", action: "chat_settings", label: "read_receipt_on", value: nil)
            AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "more", action: "chat_settings", label: "read_receipt_on")
        } else {
            AnalyticsHelper.shared.sendGoogleAnalytic(category: "more", action: "chat_settings", label: "read_receipt_off", value: nil)
            AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "more", action: "chat_settings", label: "read_receipt_off")
        }
    }
    
    @IBAction func changeLastSeen(_ sender: UISwitch) {
        if sender.isOn {
            AnalyticsHelper.shared.sendGoogleAnalytic(category: "more", action: "chat_settings", label: "last_seen_on", value: nil)
            AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "more", action: "chat_settings", label: "last_seen_on")
        } else {
            AnalyticsHelper.shared.sendGoogleAnalytic(category: "more", action: "chat_settings", label: "last_seen_off", value: nil)
            AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "more", action: "last_seen_off", label: "touch")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
