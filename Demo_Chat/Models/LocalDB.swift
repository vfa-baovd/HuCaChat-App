//
//  LocalDB.swift
//  Demo_Chat
//
//  Created by HungNV on 8/30/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import Foundation
import FMDB

class LocalDB {
    private static let localInastance: LocalDB = LocalDB()
    static func shared() -> LocalDB {
        return localInastance
    }
    
    private let kSQLFilename: String = "local"
    private let kTableMusic = "musics"
    private var queue: FMDatabaseQueue!
    
    init() {
        let filename: String = Helper.documentFolder() + "/\(kSQLFilename).db"
        if !FileManager.default.fileExists(atPath: filename) {
            let srcFilename: String = Bundle.main.path(forResource: kSQLFilename, ofType: "db")!
            do {
                try FileManager.default.copyItem(atPath: srcFilename, toPath: filename)
            } catch let error {
                #if DEBUG
                    print(error.localizedDescription)
                #endif
            }
        }
        
        self.queue = FMDatabaseQueue(path: filename)
        self.queue.inDatabase { (db: FMDatabase) in
            db.open()
            let lastVersion: String = Helper.shared.lastVersion()
            let currentVersion: String = Helper.shared.getVersionOfApp()
            
            if currentVersion.compare(lastVersion, options: .numeric) == .orderedDescending {
                Helper.shared.saveUserDefault(key: kLastVersion, value: currentVersion)
            }
            db.close()
        }
    }
    
    func getMusicInLocalDB(response: @escaping (_ musics:[MusicInfo]?)->()) {
        var musics: [MusicInfo] = [MusicInfo]()
        self.queue.inDatabase { (db: FMDatabase) in
            guard db.open() else { return }
            do {
                let stmt: FMResultSet = try db.executeQuery("SELECT * FROM \(kTableMusic) ORDER BY title", values: nil)
                while stmt.next() {
                    musics.append(MusicInfo(stmt.resultDictionary as NSDictionary!))
                }
            } catch let error {
                #if DEBUG
                    print(error.localizedDescription)
                #endif
            }
            
            db.close()
            response(musics)
        }
    }
    
    func addMusicInLocalDB(obj: Music, response: @escaping(Bool) -> Void) {
        let keys: String = "id, title, artist, avatar, urlJunDownload, urlSource, siteId, hostName, musicDownloadState"
        let vChar: String = "?, ?, ?, ?, ?, ?, ?, ?, ?"
        
        let values = [obj.id, obj.title, obj.artist, "\(obj.id).jpg", "\(obj.id).mp3", obj.urlSource, obj.siteId, obj.hostName, obj.musicDownloadState.rawValue] as [Any]
        
        self.queue.inDatabase { (db: FMDatabase) in
            guard db.open() else { return }
            let isOK = db.executeUpdate("INSERT INTO \(kTableMusic) (\(keys)) VALUES (\(vChar))", withArgumentsIn: values)
            db.close()
            if isOK {
                response(true)
            } else {
                response(false)
            }
        }
    }
    
    func addSongInLocalDB(obj: SongModel) {
        let keys: String = "id, title, artist, avatar, urlJunDownload, lyricsUrl"
        let vChar: String = "?, ?, ?, ?, ?, ?"
        
        let values = [obj.id, obj.title, obj.singer, "\(obj.fileName).png", "\(obj.fileName).mp3", "\(obj.fileName).lrc"] as [Any]
        
        self.queue.inDatabase { (db: FMDatabase) in
            guard db.open() else { return }
            db.executeUpdate("INSERT INTO \(kTableMusic) (\(keys)) VALUES (\(vChar))", withArgumentsIn: values)
            db.close()
        }
    }
}
