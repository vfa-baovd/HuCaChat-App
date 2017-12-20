//
//  SongListCollectionCell.swift
//  Demo_Chat
//
//  Created by HungNV on 8/8/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

class SongListCollectionCell: UICollectionViewCell {
    static let reuseIdentifier: String = "mCell"
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var tableView: UITableView!
    
    var playingIndex = -1 {
        didSet {
            let indexPath = IndexPath(row: playingIndex, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }
    
    override func awakeFromNib() {
        tableView.dataSource = self
        tableView.delegate = self
        blurView.layer.cornerRadius = 20
        blurView.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(actRotateImage(_:)), name: NSNotification.Name(rawValue: kNotificationRotateImage), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name(rawValue: kNotificationRefreshDataMusic), object: nil)
    }
    
    func actRotateImage(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let position = userInfo["position"] as? Int {
                self.playingIndex = position
            }
        }
    }
    
    func refreshData() {
        self.tableView.reloadData()
    }
}

extension SongListCollectionCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSong.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SongTableCell.reuseIdentifier, for: indexPath) as! SongTableCell
        let songModel = arrSong[indexPath.row]
        
        if playingIndex == indexPath.row {
            cell.imgViewSong.rotate()
        } else {
            cell.imgViewSong.pauseRotate()
        }
        cell.position = indexPath.row
        cell.songModel = songModel
        
        return cell
    }
}

extension SongListCollectionCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationSelectSong), object: nil, userInfo: ["position": indexPath.row])
    }
}
