//
//  NotificationViewController.swift
//  Demo_Chat
//
//  Created by HungNV on 5/2/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import Firebase

class NotificationViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    var bottomMenuView: BottomMenuView! = nil
    var hasNextData = true
    var isLoadingData = false
    var page: UInt = 0
    let refreshControl = UIRefreshControl()
    var pushs: [PushModel] = [PushModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = Define.shared.getNameNotificationScreen().uppercased()
        AnalyticsHelper.shared.setGoogleAnalytic(name: kGAIScreenName, value: "notification_screen")
        AnalyticsHelper.shared.setFirebaseAnalytic(screenName: "notification_screen", screenClass: classForCoder.description())
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
        bottomMenuView.btnAlart.isSelected = true
        bottomMenuView.currentIndex = 2
        
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
        if isLoadingData || !hasNextData {
            return
        }
        self.startLoading()
        isLoadingData = true
        
        MainDB.shared.getPushHistoryWithUserID(user_id: self.currentuserID, limit: Int32(NUM_LIMIT), skip: Int32(NUM_LIMIT*page)) { (results) in
            self.refreshControl.endRefreshing()
            self.hasNextData = UInt(results.count) == NUM_LIMIT
            
            self.pushs = results + self.pushs
            self.tableView.reloadData()
            self.stopLoading()
            self.isLoadingData = false
        }
    }

    func setupNavigation() {
        setupNavigationBar(vc: self, title: Define.shared.getNameNotificationScreen().uppercased(), leftText: nil, leftImg: nil, leftSelector: nil, rightText: nil, rightImg: nil, rightSelector: nil, isDarkBackground: true, isTransparent: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension NotificationViewController: BottomMenuViewDelegate {
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

extension NotificationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pushs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath) as! NotificationCell
        if self.pushs.count > indexPath.row {
            cell.configPush(push: self.pushs[indexPath.row], myIndex: indexPath)
            cell.delegate = self
        }
        return cell
    }
}

extension NotificationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView is UITableView else { return }
        
        if refreshControl.isRefreshing {
            if hasNextData {
                self.loadData()
            } else {
                refreshControl.endRefreshing()
            }
        }
    }
}

extension NotificationViewController: NotificationCellDelegate {
    func tappedContentView(myIndex: IndexPath) {
        
    }
}

