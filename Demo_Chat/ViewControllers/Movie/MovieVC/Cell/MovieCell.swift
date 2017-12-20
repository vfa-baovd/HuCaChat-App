//
//  MovieCell.swift
//  Demo_Chat
//
//  Created by HungNV on 8/14/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import Kingfisher

class MovieCell: UITableViewCell {
    @IBOutlet weak var vThumbnail: UIView!
    @IBOutlet weak var imgMoviePoster: UIImageView!
    @IBOutlet weak var vWrapperVote: UIView!
    @IBOutlet weak var lblWrapperVote: UILabel!
    @IBOutlet weak var vWrapperContent: UIView!
    @IBOutlet weak var lblMovieTitle: UILabel!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var vStatus: UIView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblMovieGenres: UILabel!
    @IBOutlet weak var lblMovieReview: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var lblCountLike: UILabel!
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet weak var lblCountComment: UILabel!
    @IBOutlet weak var cstImgMoviePosterOffsetHeight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        vWrapperContent.layer.cornerRadius = 5
        vWrapperContent.layer.shadowRadius = 5
        vWrapperContent.layer.shadowOpacity = 0.5
        vWrapperContent.layer.shadowOffset = CGSize(width: 0, height: 1)
        vWrapperContent.layer.shadowColor = UIColor.lightGray.cgColor
        vWrapperContent.layer.shadowPath = UIBezierPath(rect: vWrapperContent.bounds).cgPath
        vWrapperContent.layer.shouldRasterize = true
        vWrapperContent.layer.rasterizationScale = UIScreen.main.scale
        
        vWrapperVote.layer.cornerRadius = 16
        vWrapperVote.layer.shadowRadius = 16
        vWrapperVote.layer.shadowOpacity = 0.5
        vWrapperVote.layer.shadowOffset = CGSize(width: 0, height: 1)
        vWrapperVote.layer.shadowColor = UIColor(hex: "FFCD00", a: 1.0).cgColor
        vWrapperVote.layer.shadowPath = UIBezierPath(rect: vWrapperVote.bounds).cgPath
        vWrapperVote.layer.shouldRasterize = true
        vWrapperVote.layer.rasterizationScale = UIScreen.main.scale
        
        vThumbnail.layer.cornerRadius = 5
        vThumbnail.layer.shadowRadius = 5
        vThumbnail.layer.shadowOpacity = 0.5
        vThumbnail.layer.shadowOffset = CGSize(width: 0, height: 1)
        vThumbnail.layer.shadowColor = UIColor.lightGray.cgColor
        vThumbnail.layer.shadowPath = UIBezierPath(rect: imgMoviePoster.bounds).cgPath
        vThumbnail.layer.shouldRasterize = true
        vThumbnail.layer.rasterizationScale = UIScreen.main.scale
        
        vStatus.layer.cornerRadius = 3
    }

    func configCell(movie: Movie) {
        self.layoutIfNeeded()
        
        lblWrapperVote.text = movie.vote_average.convertToStringWithOneDecimal()
        lblMovieTitle.text = movie.title
        lblMovieReview.text = movie.overview
        lblTime.text = movie.release_date
        lblCountLike.text = String(movie.vote_count)
        
        var genreNameList:[String] = [String]()
        let gensDis = MainDB.shared.getDictionFromGenreList()
        for genre in movie.genres {
            if gensDis.count == 0 {break}
            guard let item = gensDis[genre] else { continue }
            genreNameList.append(item)
        }
        lblMovieGenres.text = genreNameList.joined(separator: ", ")
        
        if let url = URL(string: movie.poster_path) {
            imgMoviePoster.kf.indicatorType = .activity
            imgMoviePoster.kf.indicator?.startAnimatingView()
            let resource = ImageResource(downloadURL: url, cacheKey: movie.poster_path)
            imgMoviePoster.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "updating_movie_backdrop"), options: [.transition(.fade(0.25)), .backgroundDecode], progressBlock: nil, completionHandler: { (img, error, cache, url) in
                if var img = img {
                    let newHeight = self.imgMoviePoster.bounds.size.width * img.size.height / img.size.width
                    self.cstImgMoviePosterOffsetHeight.constant = newHeight
                    img = img.kf.resize(to: CGSize(width: self.imgMoviePoster.bounds.size.width, height: newHeight))
                    ImageCache.default.store(img, forKey: movie.poster_path)
                    DispatchQueue.main.async(execute: {
                        self.imgMoviePoster.image = img
                        self.imgMoviePoster.kf.indicator?.stopAnimatingView()
                    })
                }else {
                    DispatchQueue.main.async(execute: {
                        self.imgMoviePoster.image = #imageLiteral(resourceName: "updating_movie_backdrop")
                        self.imgMoviePoster.kf.indicator?.stopAnimatingView()
                    })
                }
            })
        } else {
            imgMoviePoster.image = #imageLiteral(resourceName: "updating_movie_backdrop")
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
