//
//  PeopleCollectionCell.swift
//  Demo_Chat
//
//  Created by HungNV on 8/19/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

class PeopleCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imgAvatar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgAvatar.layer.cornerRadius = 10
        imgAvatar.layer.borderWidth = 0.5
        imgAvatar.layer.borderColor = Theme.shared.color_Online().cgColor
        imgAvatar.clipsToBounds = true
    }
    
    func configImagePeople(strImg: String) {
        if let img = Helper.shared.getCachedImageForPath(fileName: "\(strImg).jpg") {
            self.imgAvatar.image = img
        } else {
            self.imgAvatar.image = #imageLiteral(resourceName: "icon_recent_group")
        }
    }
}
