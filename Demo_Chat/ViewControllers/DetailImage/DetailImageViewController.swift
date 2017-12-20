//
//  DetailImageViewController.swift
//  Demo_Chat
//
//  Created by HungNV on 7/29/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import Firebase

class DetailImageViewController: BaseViewController {
    @IBOutlet weak var imageView: UIImageView!
    var url: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.enableSwipe = true
        self.setupView()
        self.loadImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsHelper.shared.setGoogleAnalytic(name: kGAIScreenName, value: "detail_image")
        AnalyticsHelper.shared.setFirebaseAnalytic(screenName: "detail_image", screenClass: classForCoder.description())
    }
    
    func setupView() {
        self.setupNavigation()
    }
    
    func setupNavigation() {
        setupNavigationBar(vc: self, title: Define.shared.getNameDetailImageScreen().uppercased(), leftText: nil, leftImg: #imageLiteral(resourceName: "arrow_back"), leftSelector: #selector(self.actBack(btn:)), rightText: nil, rightImg: nil, rightSelector: nil, isDarkBackground: true, isTransparent: true)
    }
    
    func loadImage() {
        self.startLoading()
        if let url: URL = URL(string: self.url) {
            let strURL = url.lastPathComponent
            if let image = Helper.shared.getCachedImageForPath(fileName: "big_\(strURL)") {
                DispatchQueue.main.async {
                    self.imageView.image = image
                    self.stopLoading()
                }
            } else {
                DispatchQueue.global().async {
                    do {
                        let data: Data = try Data(contentsOf: url)
                        DispatchQueue.main.async {
                            if let img = UIImage(data: data) {
                                self.imageView.image = img
                                Helper.shared.cacheImageThumbnail(image: img, fileName: "big_\(strURL)")
                            }
                            self.stopLoading()
                        }
                    } catch {
                        self.stopLoading()
                    }
                }
            }
        }
    }
    
    func actBack(btn: UIButton) {
        _ = navigationController?.popViewController(animated: true)
        
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "chat_and_group", action: "detail_image", label: "back", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "chat_and_group", action: "detail_image", label: "back")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
