//
//  AboutViewController.swift
//  Demo_Chat
//
//  Created by HungNV on 8/16/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    lazy var appList:[ApplicationModel] = [ApplicationModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.loadData()
    }

    func setupView() {
        self.setupNavigation()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        let cellSize:CGFloat = floor((UIManager.screenWidth() - 12) / 2)
        
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            self.collectionView.isPagingEnabled = true
            layout.itemSize = CGSize(width: cellSize, height: cellSize)
        }
    }
    
    func setupNavigation() {
        setupNavigationBar(vc: self, title: Define.shared.getNameAboutScreen().uppercased(), leftText: nil, leftImg: #imageLiteral(resourceName: "arrow_back"), leftSelector: #selector(self.actBack(btn:)), rightText: nil, rightImg: nil, rightSelector: nil, isDarkBackground: true, isTransparent: true)
    }
    
    func actBack(btn: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func loadData() {
        self.startLoading()
        MainDB.shared.getAllApplicationClass { (results) in
            self.appList = results
            self.collectionView.reloadData()
            self.stopLoading()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK:- UICollectionView
extension AboutViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AboutCell", for: indexPath) as! AboutCell
        
        let app = appList[indexPath.item]
        cell.setupCell(info: app, UIColor.red)
        
        return cell
    }
}

extension AboutViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let app = appList[indexPath.row]
        if let url = URL(string: app.app_url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
