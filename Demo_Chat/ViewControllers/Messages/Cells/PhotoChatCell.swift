//
//  PhotoChatCell.swift
//  Demo_Chat
//
//  Created by Nguyen Van Hung on 3/1/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

protocol PhotoChatCellDelegate: class {
    func tappedMessageTypePhoto(cell: PhotoChatCell, tap: UITapGestureRecognizer)
}

class PhotoChatCell: ChatCell {

    @IBOutlet weak var imgMessage: UIImageView!
    @IBOutlet weak var cstImgMessageOffsetWidth: NSLayoutConstraint!
    @IBOutlet weak var cstImgMessageOffsetHeight: NSLayoutConstraint!
    
    weak var delegate: PhotoChatCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configImgMessage()
        
        let tagGesture = UITapGestureRecognizer(target: self, action: #selector(tappedMessageTypePhoto(tap:)))
        self.imgMessage?.addGestureRecognizer(tagGesture)
        self.imgMessage.isUserInteractionEnabled = true
    }
    
    func configImgMessage() {
        self.imgMessage.layer.cornerRadius = 5
        self.imgMessage.clipsToBounds = true
    }
    
    func tappedMessageTypePhoto(tap: UITapGestureRecognizer) {
        self.delegate?.tappedMessageTypePhoto(cell: self, tap: tap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
