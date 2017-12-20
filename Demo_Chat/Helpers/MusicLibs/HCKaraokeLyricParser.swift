//
//  HCKaraokeLyricParser.swift
//  Demo_Chat
//
//  Created by HungNV on 8/7/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

protocol HCKaraokeLyricParser {
    func lyricFromLRCString(lrcStr: String) -> HCKaraokeLyric
}

extension HCKaraokeLyricParser {
    func lyricFromLocationPathFileName(lrcFileName: String) -> HCKaraokeLyric? {
//        guard let filePath = Bundle.main.path(forResource: lrcFileName, ofType: "lrc") else { return nil }
        let filePath = Helper.documentFolder() + "/\(lrcFileName)"
        
        if let lyricContent = try? String(contentsOfFile: filePath, encoding: String.Encoding.utf8) {
            return self.lyricFromLRCString(lrcStr: lyricContent)
        }
        
        return nil
    }
    
    func timeStr2Float(strTime: String) -> CGFloat {
        var result: CGFloat = 0
        
        let timeParts = strTime.components(separatedBy: ":")
        if timeParts.count > 1 {
            let min = Double(timeParts[0]) ?? 0
            let sec = Double(timeParts[1]) ?? 0
            result = CGFloat(min * 60 + sec)
        }
        
        return result
    }
}

struct HCBasicKaraokeLyricParser: HCKaraokeLyricParser {
    func lyricFromLRCString(lrcStr: String) -> HCKaraokeLyric {
        let lyricRows = lrcStr.components(separatedBy: CharacterSet.newlines)
        var lyricDict: Dictionary<CGFloat, String> = Dictionary<CGFloat, String>()
        
        var title: String = "", artist = "", album = "", by = ""
        
        for row in lyricRows {
            if row.hasPrefix("[") {
                if row.hasPrefix("[ti:") || row.hasPrefix("[ar:") || row.hasPrefix("[al:") || row.hasPrefix("[by:") {
                    let text = row[row.characters.index(row.startIndex, offsetBy: 5)...row.characters.index(row.endIndex, offsetBy: -2)]
                    
                    let tag = row[row.characters.index(row.startIndex, offsetBy: 1)...row.characters.index(row.startIndex, offsetBy: 2)]
                    switch tag {
                    case "ti":
                        title = text
                        break
                    case "ar":
                        artist = text
                        break
                    case "al":
                        album = text
                        break
                    case "by":
                        by = text
                        break
                    default:
                        #if DEBUG
                            print("Unknow text")
                        #endif
                    }
                } else {
                    let textParts = row.components(separatedBy: CharacterSet(charactersIn: "[]"))
                    let lyricText = textParts[2]
                    let keyTime = self.timeStr2Float(strTime: textParts[1])
                    lyricDict[keyTime] = lyricText
                }
            }
        }
        
        var lyric = HCKaraokeLyric(title: title, singer: artist, composer: by, album: album)
        lyric.content = lyricDict
        
        return lyric
    }
}
