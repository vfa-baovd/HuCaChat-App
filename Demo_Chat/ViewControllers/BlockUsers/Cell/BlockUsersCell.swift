//
//  BlockUsersCell.swift
//  Demo_Chat
//
//  Created by HungNV on 5/4/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

protocol BlockUsersCellDelegate: class {
    func tappedContentView(myIndex: IndexPath)
}

class BlockUsersCell: SwipeCell {

    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblAvatar: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    
    weak var delegateBlock: BlockUsersCellDelegate?
    var myIndex: IndexPath = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedContentView(tap:)))
        vContent.addGestureRecognizer(tapGesture)
    }
    
    func configUser(user: UserModel, myIndex: IndexPath) {
        let display_name = user.display_name
        lblName.text = display_name
        lblEmail.text = user.email
        self.myIndex = myIndex
        
        if let image = user.avatar_img {
            imgAvatar.image = image
            lblAvatar.text = ""
            lblAvatar.isHidden = true
        } else {
            imgAvatar.image = nil
            lblAvatar.text = display_name.substring(to: display_name.index(display_name.startIndex, offsetBy: 1)).uppercased()
            lblAvatar.isHidden = false
        }
    }
    
    func configView() {
        vContent.backgroundColor = UIColor.white
        vContent.layer.cornerRadius = 5
        vContent.layer.shadowOpacity = 0.5
        vContent.layer.shadowOffset = CGSize(width: 0, height: 1)
        vContent.layer.shadowColor = UIColor.lightGray.cgColor
        vContent.layer.shadowRadius = 5
        
        imgAvatar.backgroundColor = Theme.shared.color_App()
        imgAvatar.layer.cornerRadius = 20
        imgAvatar.layer.borderWidth = 1
        imgAvatar.layer.borderColor = Theme.shared.color_App().cgColor
        imgAvatar.clipsToBounds = true
    }
    
    func tappedContentView(tap: UITapGestureRecognizer) {
        self.delegateBlock?.tappedContentView(myIndex: self.myIndex)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
