//
//  SongTableCell.swift
//  Demo_Chat
//
//  Created by HungNV on 8/8/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

class SongTableCell: UITableViewCell {

    static let reuseIdentifier: String = "mtbCell"
    
    @IBOutlet weak var lblSinger: UILabel!
    @IBOutlet weak var lblSongName: UILabel!
    @IBOutlet weak var imgViewSong: UIImageView!
    
    var position = 0
    var songModel: MusicInfo? {
        didSet {
            setupCell()
        }
    }
    
    func setupCell() {
        lblSongName.text = songModel?.title
        let imgPath = Helper.documentFolder() + "/\((songModel?.avatar)!)"
        imgViewSong.image = UIImage.init(contentsOfFile: imgPath)
        lblSinger.text = songModel?.artist
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgViewSong.layer.cornerRadius = imgViewSong.bounds.size.width / 2
        imgViewSong.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(actRotateImage(_:)), name: NSNotification.Name(rawValue: kNotificationRotateImage), object: nil)
    }
    
    func actRotateImage(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let position = userInfo["position"] as? Int {
                if position == self.position {
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
                } else {
                    imgViewSong.stopRotate()
                }
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
