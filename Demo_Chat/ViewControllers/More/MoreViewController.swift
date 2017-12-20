//
//  MoreViewController.swift
//  Demo_Chat
//
//  Created by HungNV on 5/3/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import NCMB
import Firebase

class MoreViewController: BaseViewController {
    @IBOutlet weak var vStatus: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblLanguage: UILabel!
    @IBOutlet weak var vBlockUsers: UIView!
    @IBOutlet weak var lblNumBlockUsers: UILabel!
    @IBOutlet weak var vPicker: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var swAllowPush: UISwitch!
    @IBOutlet weak var cstViewOffsetTop: NSLayoutConstraint!
    @IBOutlet weak var cstViewOffsetHeight: NSLayoutConstraint!
    @IBOutlet weak var hStatusMessage: UILabel!
    @IBOutlet weak var hOnlineStatus: UILabel!
    @IBOutlet weak var hChatSettings: UILabel!
    @IBOutlet weak var hNotificationSettings: UILabel!
    @IBOutlet weak var hBannersSound: UILabel!
    @IBOutlet weak var hLanguage: UILabel!
    @IBOutlet weak var hBlockUsers: UILabel!
    @IBOutlet weak var hAppGame: UILabel!
    @IBOutlet weak var hAllowLocation: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var swAllowLocation: UISwitch!
    
    var bottomMenuView: BottomMenuView! = nil
    var listData:[String] = [String]()
    var installation: NCMBInstallation?
    var whoSetPickerView: String = ""
    var valueHistoryLanguage: String = ""
    var valueHistoryStatus: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshDidFinishedLanguage()
        
        if let numBlockUsers = self.appDelegate.currUser?.block_users.count {
            lblNumBlockUsers.text = "\(numBlockUsers)"
        } else {
            lblNumBlockUsers.text = "0"
        }
        
        AnalyticsHelper.shared.setGoogleAnalytic(name: kGAIScreenName, value: "more_screen")
        AnalyticsHelper.shared.setFirebaseAnalytic(screenName: "more_screen", screenClass: classForCoder.description())
        
        GoogleAdMobHelper.shared.showBannerView()
        self.cstViewOffsetTop.constant = 50
        self.cstViewOffsetHeight.constant = -100
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDidFinishedLanguage), name: NSNotification.Name(rawValue: kNotificationRefreshLanguage), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GoogleAdMobHelper.shared.hideBannerView()
        self.cstViewOffsetTop.constant = 0
        self.cstViewOffsetHeight.constant = 0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kNotificationRefreshLanguage), object: nil)
    }
    
    func setupView() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.setupNavigation()
        
        bottomMenuView = BottomMenuView(delegate: nil)
        bottomMenuView.layer.shadowRadius = 5
        bottomMenuView.layer.shadowOpacity = 0.3
        bottomMenuView.layer.shadowColor = UIColor.gray.cgColor
        bottomMenuView.delegate = self
        self.view.insertSubview(bottomMenuView, belowSubview: vPicker)
        
        bottomMenuView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        bottomMenuView.clearSelectButton()
        bottomMenuView.btnSetting.isSelected = true
        bottomMenuView.currentIndex = 3
        
        vStatus.layer.cornerRadius = 5
        vBlockUsers.layer.cornerRadius = 13.75
        
        pickerView.delegate = self
        pickerView.dataSource = self
        vPicker.frame = CGRect(x: 0, y: kScreenHeight, width: vPicker.frame.size.width, height: vPicker.frame.size.height)
        vPicker.isHidden = true
    }
    
    func refreshDidFinishedLanguage() {
        self.title = Define.shared.getNameMoreScreen().uppercased()
        self.hStatusMessage.text = NSLocalizedString("h_status_message", "")
        self.hOnlineStatus.text = NSLocalizedString("h_online_status", "")
        self.hChatSettings.text = NSLocalizedString("h_chat_settings", "")
        self.hNotificationSettings.text = NSLocalizedString("h_notification_settings", "")
        self.hBannersSound.text = NSLocalizedString("h_banners_sound", "")
        self.hLanguage.text = NSLocalizedString("h_language", "")
        self.hBlockUsers.text = NSLocalizedString("h_blocked_users", "")
        self.hAppGame.text = NSLocalizedString("h_app_game", "")
        self.btnCancel.setTitle(NSLocalizedString("h_cancel", ""), for: .normal)
        self.btnDone.setTitle(NSLocalizedString("h_done", ""), for: .normal)
        self.hAllowLocation.text = NSLocalizedString("h_allow_location", "")
        
        MainDB.shared.isLoading = false
        MainDB.shared.loadGenreList()
    }
    
    func setupData() {
        self.ref.child("Users").child(self.currentuserID).child("is_online").observeSingleEvent(of: .value, with: { (snap) in
            let is_online = snap.value as? String ?? ""
            self.lblStatus.text = is_online
            self.configStatusColor(is_online: is_online)
            self.valueHistoryStatus = is_online
        })
        
        self.getInstallation { (installation) in
            if (installation?.object(forKey: "allow_push") != nil) {
                self.installation = installation
                self.swAllowPush.isOn = installation?.object(forKey: "allow_push") as! Bool
            }
        }
        
        if let isAllowLocation = Helper.shared.getUserDefault(key: kAllowLocation) {
            self.swAllowLocation.isOn = isAllowLocation as! Bool
        }
        
        switch Helper.shared.currentLanguageCode() {
        case LANGUAGE_CODE_JA:
            self.lblLanguage.text = "日本語"
            self.valueHistoryLanguage = "日本語"
            break
        case LANGUAGE_CODE_VI:
            self.valueHistoryLanguage = "Tiếng Việt"
            self.lblLanguage.text = "Tiếng Việt"
            break
        default:
            self.lblLanguage.text = "English"
            self.valueHistoryLanguage = "English"
            break
        }
    }
    
    func getInstallation(completionHandler: @escaping(NCMBInstallation?) -> Void) {
        let currInstallation = NCMBInstallation.current()
        let query = NCMBInstallation.query()
        query?.whereKey("deviceToken", equalTo: currInstallation?.deviceToken)
        query?.getFirstObjectInBackground({ (object, error) in
            if (error == nil && object != nil) {
                completionHandler(object as? NCMBInstallation)
            } else {
                completionHandler(nil)
            }
        })
    }
    
    func configStatusColor(is_online: String?) {
        if is_online == "Available" {
            vStatus.backgroundColor = Theme.shared.color_Online()
        } else if is_online == "Away" {
            vStatus.backgroundColor = Theme.shared.color_Away()
        } else if is_online == "Busy" {
            vStatus.backgroundColor = Theme.shared.color_Busy()
        } else {
            vStatus.backgroundColor = Theme.shared.color_Offline()
        }
    }
    
    func hiddenPickerView() {
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseIn], animations: {
            self.vPicker.frame = CGRect(x: 0, y: kScreenHeight, width: self.vPicker.frame.size.width, height: self.vPicker.frame.size.height)
        }) { (finished: Bool) in
            self.vPicker.isHidden = true
        }
    }
    
    func showPickerView() {
        self.vPicker.isHidden = false
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseIn], animations: {
            self.vPicker.frame = CGRect(x: 0, y: kScreenHeight - 150, width: self.vPicker.frame.size.width, height: self.vPicker.frame.size.height)
        }) { (finished: Bool) in
        }
    }
    
    func setupNavigation() {
        setupNavigationBar(vc: self, title: Define.shared.getNameMoreScreen().uppercased(), leftText: nil, leftImg: nil, leftSelector: nil, rightText: nil, rightImg: nil, rightSelector: nil, isDarkBackground: true, isTransparent: true)
    }
    
    //MARK:- Action
    @IBAction func actStatusMessage(_ sender: Any) {
        let statusMessageVC = self.storyboard?.instantiateViewController(withIdentifier: "StatusMessageVC") as! StatusMessageViewController
        self.navigationController?.pushViewController(statusMessageVC, animated: true)
        
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "more", action: "status_message", label: "update", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "more", action: "status_message", label: "update")
    }
    
    @IBAction func actOnlineStatus(_ sender: Any) {
        self.whoSetPickerView = "status"
        self.listData = ["Available", "Away", "Offline", "Busy"]
        self.showPickerView()
        pickerView.reloadAllComponents()
    }
    
    @IBAction func actChatSettings(_ sender: Any) {
        let chatSettingsVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatSettingsVC") as! ChatSettingsViewController
        self.navigationController?.pushViewController(chatSettingsVC, animated: true)
    }
    
    @IBAction func actNotificationSettings(_ sender: Any) {
    }
    
    @IBAction func changeAllowPush(_ sender: Any) {
        installation?.setObject(self.swAllowPush.isOn, forKey: "allow_push")
        installation?.saveInBackground({ (error) in
            if error != nil {
                let isOn = self.swAllowPush.isOn ? "ON" : "OFF"
                #if DEBUG
                    print("Update push: \(isOn)")
                #endif
            }
        })
    }
    
    @IBAction func changeAllowLocation(_ sender: Any) {
        Helper.shared.saveUserDefault(key: kAllowLocation, value: self.swAllowLocation.isOn)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationPrivateLocation), object: nil, userInfo: nil)
    }
    
    @IBAction func actLanguage(_ sender: Any) {
        self.whoSetPickerView = "language"
        self.listData = ["English", "Tiếng Việt", "日本語"]
        self.showPickerView()
        pickerView.reloadAllComponents()
    }
    
    @IBAction func actBlockUsers(_ sender: Any) {
        let blockUsersVC = self.storyboard?.instantiateViewController(withIdentifier: "BlockUsersVC") as! BlockUsersViewController
        self.navigationController?.pushViewController(blockUsersVC, animated: true)
        
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "more", action: "block_user", label: "touch", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "more", action: "block_user", label: "touch")
    }
    
    @IBAction func actGames(_ sender: Any) {
        let aboutVC = self.storyboard?.instantiateViewController(withIdentifier: "AboutVC") as! AboutViewController
        self.navigationController?.pushViewController(aboutVC, animated: true)
        
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "more", action: "game", label: "touch", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "more", action: "game", label: "touch")
    }
    
    @IBAction func actCancel(_ sender: Any) {
        if whoSetPickerView == "status" {
            self.lblStatus.text = valueHistoryStatus
            self.configStatusColor(is_online: valueHistoryStatus)
        } else {
            self.lblLanguage.text = valueHistoryLanguage
        }
        
        self.hiddenPickerView()
    }
    
    @IBAction func actDone(_ sender: Any) {
        let row: Int = pickerView.selectedRow(inComponent: 0)
        if whoSetPickerView == "status" {
            self.valueHistoryStatus =  self.listData[row]
            self.lblStatus.text = self.listData[row]
            self.ref.child("Users").child(self.currentuserID).child("is_online").setValue(self.listData[row])
        } else {
            self.valueHistoryLanguage = self.listData[row]
            self.lblLanguage.text = self.listData[row]
            var language = self.listData[row]
            if language == "日本語" {
                language = LANGUAGE_CODE_JA
            } else if language == "Tiếng Việt" {
                language = LANGUAGE_CODE_VI
            } else {
                language = LANGUAGE_CODE_EN
            }
            Helper.shared.saveUserDefault(key: LANGUAGE_KEY, value: language)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationRefreshLanguage), object: nil, userInfo: nil)
        self.hiddenPickerView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension MoreViewController: BottomMenuViewDelegate {
    func didSelectedBtnHome(_: BottomMenuView!) {
        let _ = self.navigationController?.popToRootViewController(animated: false)
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

extension MoreViewController: UIPickerViewDataSource {
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.listData.count
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = Theme.shared.color_App()
        pickerLabel.font = Theme.shared.font_primaryLight(size: FontSize.medium)
        pickerLabel.text = self.listData[row]
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.listData[row]
    }
}

extension MoreViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if listData.count > 3 {
            self.lblStatus.text = self.listData[row]
            
            switch row {
            case 0:
                vStatus.backgroundColor = Theme.shared.color_Online()
                
                AnalyticsHelper.shared.sendGoogleAnalytic(category: "more", action: "online_status", label: "available", value: nil)
                AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "more", action: "online_status", label: "available")
                break
            case 1:
                vStatus.backgroundColor = Theme.shared.color_Away()
                
                AnalyticsHelper.shared.sendGoogleAnalytic(category: "more", action: "online_status", label: "away", value: nil)
                AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "more", action: "online_status", label: "away")
                break
            case 2:
                vStatus.backgroundColor = Theme.shared.color_Offline()
                
                AnalyticsHelper.shared.sendGoogleAnalytic(category: "more", action: "online_status", label: "offline", value: nil)
                AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "more", action: "online_status", label: "offline")
                break
            case 3:
                vStatus.backgroundColor = Theme.shared.color_Busy()
                
                AnalyticsHelper.shared.sendGoogleAnalytic(category: "more", action: "online_status", label: "busy", value: nil)
                AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "more", action: "online_status", label: "busy")
                break
            default:
                break
            }
        } else {
            self.lblLanguage.text = self.listData[row]
            
            switch row {
            case 0:
                AnalyticsHelper.shared.sendGoogleAnalytic(category: "more", action: "language", label: "english", value: nil)
                AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "more", action: "language", label: "english")
                break
            case 1:
                AnalyticsHelper.shared.sendGoogleAnalytic(category: "more", action: "language", label: "vietnamese", value: nil)
                AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "more", action: "language", label: "vietnamese")
                break
            case 2:
                AnalyticsHelper.shared.sendGoogleAnalytic(category: "more", action: "language", label: "japanese", value: nil)
                AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "more", action: "language", label: "japanese")
                break
            default:
                break
            }
        }
    }
}
