//
//  MovieDetailCollectionCell.swift
//  Demo_Chat
//
//  Created by HungNV on 8/15/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

class MovieDetailCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imgMovie: UIImageView!
    @IBOutlet weak var lblMovieName: UILabel!
    
    func setupCell(cast: Cast) {
        lblMovieName.text = cast.name
        guard let imgUrl = URL(string: cast.profile_path) else {
            self.imgMovie.image = #imageLiteral(resourceName: "updating_movie_poster")
            return
        }
        imgMovie.kf.indicatorType = .activity
        imgMovie.kf.indicator?.startAnimatingView()
        imgMovie.kf.setImage(with: imgUrl, placeholder: #imageLiteral(resourceName: "updating_movie_backdrop"), options: [.transition(.fade(0.25)), .backgroundDecode]) { (img, error, cache, url) in
            if let img = img {
                DispatchQueue.main.async(execute: {
                    self.imgMovie.image = img
                    self.imgMovie.kf.indicator?.stopAnimatingView()
                })
            } else {
                DispatchQueue.main.async(execute: {
                    self.imgMovie.image = #imageLiteral(resourceName: "updating_movie_poster")
                    self.imgMovie.kf.indicator?.stopAnimatingView()
                })
            }
        }
    }
    
    func setupCell(movie: Movie) {
        lblMovieName.text = movie.title
        guard let imgUrl = URL(string: movie.poster_path) else {
            imgMovie.image = #imageLiteral(resourceName: "updating_movie_poster")
            return
        }
        imgMovie.kf.indicatorType = .activity
        imgMovie.kf.indicator?.startAnimatingView()
        imgMovie.kf.setImage(with: imgUrl, placeholder: #imageLiteral(resourceName: "updating_movie_backdrop"), options: [.transition(.fade(0.25)), .backgroundDecode]) { (img, error, cache, url) in
            if let img = img {
                DispatchQueue.main.async(execute: {
                    self.imgMovie.image = img
                    self.imgMovie.kf.indicator?.stopAnimatingView()
                })
            } else {
                DispatchQueue.main.async(execute: {
                    self.imgMovie.image = #imageLiteral(resourceName: "updating_movie_poster")
                    self.imgMovie.kf.indicator?.stopAnimatingView()
                })
            }
        }
    }
}
