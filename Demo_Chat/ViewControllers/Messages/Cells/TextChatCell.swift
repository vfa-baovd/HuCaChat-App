//
//  TextChatCell.swift
//  Demo_Chat
//
//  Created by Nguyen Van Hung on 3/1/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

class TextChatCell: ChatCell {

    @IBOutlet weak var lblMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setcontent() {
        if let message = message {
            lblMessage.text = message.content
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
