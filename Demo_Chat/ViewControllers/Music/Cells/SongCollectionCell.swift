//
//  SongCollectionCell.swift
//  Demo_Chat
//
//  Created by HungNV on 8/8/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

class SongCollectionCell: UICollectionViewCell {
    static let reuseIdentifier: String = "pCell"
    
    @IBOutlet weak var imgViewSong: UIImageView!
    @IBOutlet weak var lblSongName: UILabel!
    @IBOutlet weak var lblSinger: UILabel!
    
    override func awakeFromNib() {
        imgViewSong.layer.cornerRadius = imgViewSong.bounds.size.width / 2
        imgViewSong.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeSong(_:)), name: NSNotification.Name(rawValue: kNotificationChangeSong), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(actRotateImage(_:)), name: NSNotification.Name(rawValue: kNotificationRotateImage), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(continueRotate), name: NSNotification.Name(rawValue: kNotificationContinueRotate), object: nil)
    }
    
    var songModel: MusicInfo? {
        didSet {
            setupCell()
        }
    }
    
    func setupCell() {
        lblSongName.text = songModel?.title
        let imgPath = Helper.documentFolder() + "/\((songModel?.avatar)!)"
        let img = UIImage.init(contentsOfFile: imgPath)
        imgViewSong.image = img
        lblSinger.text = songModel?.artist
    }
    
    func changeSong(_ notification: Notification) {
        imgViewSong.layer.removeAllAnimations()
        if let userInfo = notification.userInfo {
            if let position = userInfo["position"] as? Int {
                self.songModel = arrSong[position]
            }
        }
    }
    
    func actRotateImage(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let playing = userInfo["playing"] as? Bool {
                if playing {
                    imgViewSong.pauseRotate()
                } else {
                    if let currentTime = userInfo["currentTime"] as? Double {
                        if currentTime > 0 {
                            imgViewSong.resumeRotate()
                        } else {
                            imgViewSong.rotate()
                        }
                    }
                }
            }
        }
    }
    
    func continueRotate() {
        imgViewSong.rotate()
    }
}
