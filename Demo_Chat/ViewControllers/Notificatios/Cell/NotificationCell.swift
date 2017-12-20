//
//  NotificationCell.swift
//  Demo_Chat
//
//  Created by HungNV on 5/2/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

protocol NotificationCellDelegate: class {
    func tappedContentView(myIndex: IndexPath)
}

class NotificationCell: UITableViewCell {
    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    
    weak var delegate: NotificationCellDelegate?
    var myIndex: IndexPath = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedContentView(tap:)))
        vContent.addGestureRecognizer(tapGesture)
    }
    
    func configPush(push: PushModel, myIndex: IndexPath) {
        lblTitle.text = self.createTitleMessage(send_name: push.push_title)
        lblContent.text = push.message_content
        self.myIndex = myIndex
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
    
    func createTitleMessage(send_name: String) -> String {
        var title = ""
        if (Helper.shared.currentLanguageCode() == LANGUAGE_CODE_JA) {
            title = "\(send_name)\(Define.shared.getTitleMessageTemplate())"
        } else {
            title = "\(Define.shared.getTitleMessageTemplate()) \(send_name)"
        }
        
        return title
    }
    
    func tappedContentView(tap: UITapGestureRecognizer) {
        self.delegate?.tappedContentView(myIndex: self.myIndex)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
