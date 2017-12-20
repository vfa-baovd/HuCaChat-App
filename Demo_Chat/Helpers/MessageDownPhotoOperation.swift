//
//  MessageDownPhotoOperation.swift
//  Demo_Chat
//
//  Created by HungNV on 3/8/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

enum PhotoPosition {
    case avatar
    case message
}

class MessageDownPhotoOperation: DownloadPhotoOperation {
    let photoPosition: PhotoPosition
    
    init(indexPath: IndexPath, photoURL: String, photoPosition: PhotoPosition, delegate: DownloadPhotoOperationDelegate?) {
        self.photoPosition = photoPosition
        
        super.init(indexPath: indexPath, photoURL: photoURL, delegate: delegate)
    }
}
