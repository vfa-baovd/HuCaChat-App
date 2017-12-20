//
//  AboutCell.swift
//  Demo_Chat
//
//  Created by HungNV on 8/16/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

class AboutCell: UICollectionViewCell {
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var vColor: kUIColorView!
    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgThumbnail.layer.cornerRadius = 20
        imgThumbnail.clipsToBounds = true
    }
    
    func setupCell(info: ApplicationModel, _ color: UIColor) {
        DownloadHelper.shared.downloadImageWithFileName(fileName: info.app_icon) { (image) in
            self.imgThumbnail.image = image
        }
        vColor.isCoupon = true
        vColor.image = nil
        vColor.couponText = NSLocalizedString("h_\(info.app_category)", "").uppercased()
        
        vColor.triangleColor = UIColor.orange
        lblName.text = info.app_name
    }
}
