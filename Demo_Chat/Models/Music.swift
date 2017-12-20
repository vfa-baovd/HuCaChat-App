//
//  Music.swift
//  Demo_Chat
//
//  Created by HungNV on 8/29/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import Foundation

struct Music {
    var id: String
    var title: String = ""
    var artist: String = ""
    var avatar: String = ""
    var urlJunDownload: String = ""
    var lyricsUrl: String = ""
    var urlSource: String = ""
    var siteId: String = ""
    var hostName: String = ""
    var musicDownloadState: MusicDownloadState = .Avaiable
    
    init?(jsonData: [String: Any]) {
        guard let id = jsonData["Id"] as? String else { return nil }
        guard let title = jsonData["Title"] as? String else { return nil }
        guard let avatar = jsonData["Avatar"] as? String else { return nil }
        guard let urlJunDownload = jsonData["UrlJunDownload"] as? String else { return nil }
        
        self.id = id
        self.title = title
        self.avatar = avatar
        self.urlJunDownload = urlJunDownload
        
        if let artist = jsonData["Artist"] as? String {
            self.artist = artist
        }
        
        if let lyricsUrl = jsonData["LyricsUrl"] as? String {
            self.lyricsUrl = lyricsUrl
        }
        
        if let urlSource = jsonData["UrlSource"] as? String {
            self.urlSource = urlSource
        }
        
        if let siteId = jsonData["SiteId"] as? String {
            self.siteId = siteId
        }
        
        if let hostName = jsonData["HostName"] as? String {
            self.hostName = hostName
        }
    }
    
//    init?(data: [String: Any]) {
//        guard let id = data[""] as? String else { return nil }
//        self.id = id
//        
//    }
}
