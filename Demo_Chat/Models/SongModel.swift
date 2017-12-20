//
//  SongModel.swift
//  Demo_Chat
//
//  Created by HungNV on 8/8/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

struct SongModel {
    var id: String
    var fileName: String
    var type: String
    var title: String
    var singer: String
    var isPlaying: Bool = false
    
    init(id: String, fileName: String, type: String, title: String, singer: String, isPlaying: Bool) {
        self.id = id
        self.fileName = fileName
        self.type = type
        self.title = title
        self.singer = singer
        self.isPlaying = isPlaying
    }
}
