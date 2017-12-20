//
//  HCKaraokeLyric.swift
//  Demo_Chat
//
//  Created by HungNV on 8/7/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

struct HCKaraokeLyric {
    var title: String
    var singer: String
    var composer: String
    var album: String
    var content: Dictionary<CGFloat,String>?
    
    init(title: String, singer: String, composer: String, album: String) {
        self.title = title
        self.singer = singer
        self.composer = composer
        self.album = album
    }
}
