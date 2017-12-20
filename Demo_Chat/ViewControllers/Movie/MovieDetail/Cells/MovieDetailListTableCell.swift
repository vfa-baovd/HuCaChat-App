//
//  MovieDetailListTableCell.swift
//  Demo_Chat
//
//  Created by HungNV on 8/15/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

protocol MovieDetailListTableCellDelegate: class {
    func moveToMoveListVCBy(castId: Int, castName: String)
}

class MovieDetailListTableCell: UITableViewCell {
    @IBOutlet weak var vNoResult: UIView!
    @IBOutlet weak var lblNoResult: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var movieList:[Movie] = [Movie]()
    lazy var castList:[Cast] = [Cast]()
    weak var delegate : MovieDetailListTableCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.dataSource = self
        collectionView.delegate = self
        lblNoResult.text = NSLocalizedString("h_no_result", "")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension MovieDetailListTableCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if movieList.count > 0 {
            return movieList.count
        } else {
            return castList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieDetailCollectionCell" , for: indexPath) as! MovieDetailCollectionCell
        
        if movieList.count > 0 {
            let movie = movieList[indexPath.item]
            cell.setupCell(movie: movie)
        } else {
            let cast = castList[indexPath.item]
            cell.setupCell(cast: cast)
        }
        
        return cell
    }
}

extension MovieDetailListTableCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if movieList.count > 0 {
            let movie = movieList[indexPath.item]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationMovieDetail), object: nil, userInfo: ["movieId": movie.id])
        } else if castList.count > 0 {
            let cast = castList[indexPath.item]
            delegate?.moveToMoveListVCBy(castId: cast.id, castName: cast.name)
        }
    }
}
