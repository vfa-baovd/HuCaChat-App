//
//  SearchCell.swift
//  Demo_Chat
//
//  Created by HungNV on 8/29/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import Kingfisher

class SearchCell: UITableViewCell {

    @IBOutlet weak var lblSinger: UILabel!
    @IBOutlet weak var lblSongName: UILabel!
    @IBOutlet weak var imgViewSong: UIImageView!
    @IBOutlet weak var lblStatus: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lblStatus.layer.cornerRadius = lblStatus.frame.size.height / 2
        lblStatus.layer.masksToBounds = true
        
        imgViewSong.layer.cornerRadius = imgViewSong.bounds.size.width / 2
        imgViewSong.clipsToBounds = true
    }
    
    func configCell(music: Music) {
        lblSongName.text = music.title
        lblSinger.text = music.artist
        self.correctDownloadButton(music.musicDownloadState)
        
        guard let imgUrl = URL(string: music.avatar) else {
            self.imgViewSong.image = #imageLiteral(resourceName: "updating_movie_poster")
            return
        }
        imgViewSong.kf.indicatorType = .activity
        imgViewSong.kf.indicator?.startAnimatingView()
        imgViewSong.kf.setImage(with: imgUrl, placeholder: #imageLiteral(resourceName: "updating_movie_backdrop"), options: [.transition(.fade(0.25)), .backgroundDecode]) { (img, error, cache, url) in
            if let img = img {
                DispatchQueue.main.async(execute: {
                    self.imgViewSong.image = img
                    self.imgViewSong.kf.indicator?.stopAnimatingView()
                })
            } else {
                DispatchQueue.main.async(execute: {
                    self.imgViewSong.image = #imageLiteral(resourceName: "updating_movie_poster")
                    self.imgViewSong.kf.indicator?.stopAnimatingView()
                })
            }
        }
    }
    
    func updateStatus(music: Music) {
        self.correctDownloadButton(music.musicDownloadState)
    }

    private func correctDownloadButton(_ state: MusicDownloadState) {
        switch state {
        case .Avaiable:
            lblStatus.backgroundColor = Theme.shared.color_avaiable()
            lblStatus.text = NSLocalizedString("b_avaiable", "")
            break
            
        case .Download:
            lblStatus.backgroundColor = Theme.shared.color_download()
            lblStatus.text = NSLocalizedString("b_download", "")
            break
            
        case .Downloaded:
            lblStatus.backgroundColor = Theme.shared.color_downloaded()
            lblStatus.text = NSLocalizedString("b_downloaded", "")
            break
            
        case .Delete:
            lblStatus.backgroundColor = Theme.shared.color_delete()
            lblStatus.text = NSLocalizedString("b_delete", "")
            break
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
