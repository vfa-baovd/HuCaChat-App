//
//  Cast.swift
//  Demo_Chat
//
//  Created by HungNV on 8/15/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import Foundation

struct Cast {
    var id: Int
    var character:String
    var credit_id:String
    var name:String
    var profile_path:String = ""
    
    init?(jsonData: JSONData) {
        guard let id = jsonData["id"] as? Int else {return nil}
        guard let character = jsonData["character"] as? String else { return nil }
        guard let credit_id = jsonData["credit_id"] as? String else { return nil }
        guard let name = jsonData["name"] as? String else { return nil }
        
        self.id = id
        self.character = character
        self.credit_id = credit_id
        self.name = name
        
        if let profile_path = jsonData["profile_path"] as? String, !profile_path.isEmpty {
            self.profile_path = "\(IMAGE_API)\(PROFILE_SIZE_KEY)\(profile_path)"
        }
    }
}
