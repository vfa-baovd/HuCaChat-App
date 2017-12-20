//
//  MovieDetailTableCell.swift
//  Demo_Chat
//
//  Created by HungNV on 8/15/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

class MovieDetailTableCell: UITableViewCell {
    @IBOutlet weak var imgMoviePoster: UIImageView!
    @IBOutlet weak var vWrapperVote: UIView!
    @IBOutlet weak var lblWrapperVote: UILabel!
    @IBOutlet weak var lblMovieTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblMovieGenres: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var lblCountLike: UILabel!
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet weak var lblCountComment: UILabel!
    @IBOutlet weak var lblBudget: UILabel!
    @IBOutlet weak var lblPopularity: UILabel!
    @IBOutlet weak var lblRevenue: UILabel!
    @IBOutlet weak var lblContries: UILabel!
    @IBOutlet weak var hContry: UILabel!
    
    var movie: MovieDetail?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        vWrapperVote.layer.cornerRadius = 7.5
        vWrapperVote.layer.shadowRadius = 16
        vWrapperVote.layer.shadowOpacity = 0.5
        vWrapperVote.layer.shadowOffset = CGSize(width: 0, height: 1)
        vWrapperVote.layer.shadowColor = UIColor(hex: "FFCD00", a: 1.0).cgColor
        vWrapperVote.layer.shadowPath = UIBezierPath(rect: vWrapperVote.bounds).cgPath
        vWrapperVote.layer.shouldRasterize = true
        vWrapperVote.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func setupCell(movie: MovieDetail) {
        lblWrapperVote.text = movie.vote_average.convertToStringWithOneDecimal()
        lblPopularity.text = "\(NSLocalizedString("h_popularity", "")): \(movie.popularity.convertToStringWithOneDecimal())"
        lblMovieTitle.text = movie.title
        lblBudget.text = "\(NSLocalizedString("h_budget", "")): \(movie.budget.convertToStringWithOneDecimal())"
        lblRevenue.text = "\(NSLocalizedString("h_revenue", "")): \(movie.revenue.convertToStringWithOneDecimal())"
        lblTime.text = "\(NSLocalizedString("h_date", "")): \(movie.release_date)"
        lblCountLike.text = String(movie.vote_count)
        hContry.text = NSLocalizedString("h_country", "")
        
        var countriesList:[String] = [String]()
        for country in movie.countries {
            countriesList.append(country.name)
        }
        lblContries.text = countriesList.joined(separator: ", ")
        
        var genreNameList:[String] = [String]()
        for genre in movie.genres {
            genreNameList.append(genre.name)
        }
        lblMovieGenres.text = genreNameList.joined(separator: ", ")
        
        guard let imgUrl = URL(string: movie.poster_path) else {
            self.imgMoviePoster.image = #imageLiteral(resourceName: "updating_movie_poster")
            return
        }
        imgMoviePoster.kf.indicatorType = .activity
        imgMoviePoster.kf.indicator?.startAnimatingView()
        imgMoviePoster.kf.setImage(with: imgUrl, placeholder: #imageLiteral(resourceName: "updating_movie_backdrop"), options: [.transition(.fade(0.25)), .backgroundDecode]) { (img, error, cache, url) in
            if let img = img {
                DispatchQueue.main.async(execute: {
                    self.imgMoviePoster.image = img
                    self.imgMoviePoster.kf.indicator?.stopAnimatingView()
                })
            } else {
                DispatchQueue.main.async(execute: {
                    self.imgMoviePoster.image = #imageLiteral(resourceName: "updating_movie_poster")
                    self.imgMoviePoster.kf.indicator?.stopAnimatingView()
                })
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
