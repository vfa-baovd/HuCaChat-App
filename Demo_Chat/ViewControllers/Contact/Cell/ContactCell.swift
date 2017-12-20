//
//  ContactCell.swift
//  Demo_Chat
//
//  Created by Nguyen Van Hung on 2/26/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

protocol ContactCellDelegate: class {
    func tappedContentView(myIndex: IndexPath)
}

class ContactCell: UITableViewCell {

    @IBOutlet weak var vLineTop: UIView!
    @IBOutlet weak var vLineCenter: UIView!
    @IBOutlet weak var vLineBottom: UIView!
    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblAvatar: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var vStatus: UIView!
    
    weak var delegate: ContactCellDelegate?
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
        lblStatus.text = user.status
        self.myIndex = myIndex
        
        self.configStatusColor(is_online: user.is_online)
        
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
    
    func configView() {
        vLineCenter.layer.cornerRadius = 3.5
        
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
        
        vStatus.layer.cornerRadius = 5
    }
    
    func tappedContentView(tap: UITapGestureRecognizer) {
        self.delegate?.tappedContentView(myIndex: self.myIndex)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
