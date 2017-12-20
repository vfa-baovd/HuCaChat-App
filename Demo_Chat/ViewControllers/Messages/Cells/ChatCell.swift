//
//  ChatCell.swift
//  Demo_Chat
//
//  Created by Nguyen Van Hung on 3/1/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

protocol ChatCellDelegate: class {
    func longPressOnMessage(cell: ChatCell, longPress: UILongPressGestureRecognizer, message: Message)
}

class ChatCell: UITableViewCell {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var vContentMessage: UIView!
    
    weak var delegateChat: ChatCellDelegate?
    var message: Message!
    var longTap: UILongPressGestureRecognizer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
        if longTap == nil {
            self.longTap = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnMessage(longPress:)))
            vContentMessage.addGestureRecognizer(self.longTap!)
        }
    }
    
    func configView() {
        vContentMessage.layer.cornerRadius = 5
        vContentMessage.layer.shadowOpacity = 0.5
        vContentMessage.layer.shadowOffset = CGSize(width: 0, height: 1)
        vContentMessage.layer.shadowColor = UIColor.lightGray.cgColor
        vContentMessage.layer.shadowRadius = 5
        
        imgAvatar.backgroundColor = Theme.shared.color_Online()
        imgAvatar.layer.cornerRadius = 20
        imgAvatar.layer.borderWidth = 1
        imgAvatar.clipsToBounds = true
    }
    
    func longPressOnMessage(longPress: UILongPressGestureRecognizer) {
        if let delegate = self.delegateChat {
            delegate.longPressOnMessage(cell: self, longPress: longPress, message: message)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
