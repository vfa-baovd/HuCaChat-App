//
//  DownloadPhotoOperation.swift
//  Demo_Chat
//
//  Created by Nguyen Van Hung on 2/27/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

protocol DownloadPhotoOperationDelegate: class {
    func downloadPhotoDidFinish(operation: DownloadPhotoOperation, image: UIImage)
    func downloadPhotoDidFail(operation: DownloadPhotoOperation)
}

class DownloadPhotoOperation: Operation {
    let indexPath: IndexPath
    let photoURL: String
    weak var delegate: DownloadPhotoOperationDelegate?
    
    init(indexPath: IndexPath, photoURL: String, delegate: DownloadPhotoOperationDelegate?) {
        self.indexPath = indexPath
        self.photoURL = photoURL
        self.delegate = delegate
    }
    
    override func main() {
        if isCancelled { return }
        
        guard let url = URL(string: photoURL) else {
            handleFail()
            return
        }
        
        if isCancelled { return }
        
        guard let imgData = try? Data(contentsOf: url) else {
            handleFail()
            return
        }
        
        if isCancelled { return }
        
        if let downloadedImage = UIImage(data: imgData) {
            DispatchQueue.main.async(execute: {
                self.delegate?.downloadPhotoDidFinish(operation: self, image: downloadedImage)
            })
        }
    }
    
    func handleFail() {
        DispatchQueue.main.async(execute: {
            self.delegate?.downloadPhotoDidFail(operation: self)
        })
    }
}
