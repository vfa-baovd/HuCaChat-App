//
//  ModelData.swift
//  Demo_Chat
//
//  Created by HungNV on 8/30/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import Foundation

public class ModelData: NSObject {
    override init() {
        super.init()
    }
    
    init(_ dict:NSDictionary!) {
        super.init()
        
        if dict == nil {
            return
        }
        
        for c in Mirror(reflecting: self).children {
            let obj = dict[c.label!]
            if (obj != nil) && !(obj is NSNull) {
                self.setValue(obj, forKey: c.label!)
            }
        }
    }
    
    override public var description : String {
        var des:String = "\n"
        
        for c in Mirror(reflecting: self).children {
            if let name = c.label {
                des += name + ": \(self.value(forKey: name))\n"
            }
        }
        
        return des
    }
}

public class MusicInfo : ModelData {
    var id: String = ""
    var title: String = ""
    var artist: String = ""
    var avatar: String = ""
    var urlJunDownload: String = ""
    var lyricsUrl: String = ""
    var urlSource: String = ""
    var siteId: String = ""
    var hostName: String = ""
    var musicDownloadState: Int = 0
    var isPlaying: Bool = false
    
    var objectData: NSDictionary!
}
