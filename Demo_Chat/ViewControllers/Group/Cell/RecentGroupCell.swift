//
//  RecentGroupCell.swift
//  Demo_Chat
//
//  Created by HungNV on 5/1/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

protocol RecentGroupCellDelegate: class {
    func tappedContentView(myIndex: IndexPath)
}

class RecentGroupCell: UITableViewCell {
    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: RecentGroupCellDelegate?
    var myIndex: IndexPath = []
    lazy var people:[String] = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedContentView(tap:)))
        vContent.addGestureRecognizer(tapGesture)
        
        self.collectionView.dataSource = self
    }

    func configRecentGroupChat(recentGroup: RecentGroupChat, myIndex: IndexPath) {
        lblName.text = recentGroup.name
        self.myIndex = myIndex
        
        if let image = recentGroup.avatar_img {
            imgAvatar.image = image
        } else {
            imgAvatar.image = #imageLiteral(resourceName: "icon_recent_group")
        }
        
        self.people.removeAll()
        if let people = recentGroup.people {
            for tag in people {
                self.people.append(tag.value)
            }
            self.collectionView.reloadData()
        }
    }
    
    func configView() {
        vContent.backgroundColor = UIColor.white
        vContent.layer.cornerRadius = 5
        vContent.layer.shadowOpacity = 0.5
        vContent.layer.shadowOffset = CGSize(width: 0, height: 1)
        vContent.layer.shadowColor = UIColor.lightGray.cgColor
        vContent.layer.shadowRadius = 5
        
        imgAvatar.backgroundColor = Theme.shared.color_App()
        imgAvatar.layer.cornerRadius = 20
        imgAvatar.layer.borderWidth = 1
        imgAvatar.layer.borderColor = Theme.shared.color_App().cgColor
        imgAvatar.clipsToBounds = true
    }
    
    func tappedContentView(tap: UITapGestureRecognizer) {
        self.delegate?.tappedContentView(myIndex: self.myIndex)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension RecentGroupCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PeopleCollectionCell" , for: indexPath) as! PeopleCollectionCell
        cell.configImagePeople(strImg: self.people[indexPath.row])
        
        return cell
    }
}
