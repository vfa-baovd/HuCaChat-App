//
//  MovieDetailViewController.swift
//  Demo_Chat
//
//  Created by HungNV on 8/11/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import AVFoundation
import youtube_parser
import AVKit

class MovieDetailViewController: BaseViewController {
    @IBOutlet weak var vVideoWraper: UIView!
    @IBOutlet weak var vMovieNoResult: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblNoVideo: UILabel!
    
    var isFirstLoad = true
    let group = DispatchGroup()
    var movie: MovieDetail?
    var videos: [Video] = [Video]()
    var recommendMovies: [Movie] = [Movie]()
    var similarMovies: [Movie] = [Movie]()
    var casts: [Cast] = [Cast]()
    let avController = AVPlayerViewController()
    var movieId: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupData()
    }
    
    func setupView() {
        self.setupNavigation()
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        NotificationCenter.default.addObserver(self, selector: #selector(continueAction(notification:)), name: NSNotification.Name(rawValue: "continueAction"), object: nil)
    }
    
    func setupNavigation() {
        setupNavigationBar(vc: self, title: Define.shared.getNameDetailMovieScreen().uppercased(), leftText: nil, leftImg: #imageLiteral(resourceName: "arrow_back"), leftSelector: #selector(self.actBack(btn:)), rightText: nil, rightImg: nil, rightSelector: nil, isDarkBackground: true, isTransparent: true)
    }
    
    func actBack(btn: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func setupData() {
        if isFirstLoad {
            group.enter()
            MainDB.shared.movieDetail(id: movieId, response: { (movieDetail) in
                if let movieDetail = movieDetail {
                    self.movie = movieDetail
                }
                self.group.leave()
            })
            
            group.enter()
            MainDB.shared.getVideosByMovieId(id: movieId, response: { (videos) in
                if let videos = videos, videos.count > 0 {
                    self.videos = videos
                    for video in videos {
                        if video.type != .Trailer && video.size != 720 && video.site != "YouTube" {continue}
                        guard let youtubeURL = URL(string: "\(VIDEO_API)watch?v=\(video.key)") else {continue}
                        Youtube.h264videosWithYoutubeURL(youtubeURL, completion: { (info, error) in
                            guard let urlStr = info?["url"] as? String else {return}
                            guard let videoURL = URL(string: urlStr) else {return}
                            
                            let avPlayerView = AVPlayerLayer(player: AVPlayer(url: videoURL))
                            avPlayerView.frame = self.vVideoWraper.frame
                            self.avController.view.frame = self.vVideoWraper.frame
                            self.avController.showsPlaybackControls = true
                            //self.avController.allowsPictureInPicturePlayback = false
                            self.avController.player = avPlayerView.player
                            //self.avController.delegate = self
                            self.vVideoWraper.addSubview(self.avController.view)
                        })
                    }
                } else {
                    self.vMovieNoResult.isHidden = false
                    self.vVideoWraper.isHidden = true
                    self.lblNoVideo.text = NSLocalizedString("h_no_video", "")
                }
                self.group.leave()
            })
            
            group.enter()
            MainDB.shared.getCastListBy(movieId: movieId, page: 1, response: { (castList) in
                if let castList = castList {
                    self.casts = castList
                }
                self.group.leave()
            })
            
            group.enter()
            MainDB.shared.getRecommendMoviesBy(movieId: movieId, page: 1, response: { (movies) in
                if let movies = movies {
                    self.recommendMovies = movies
                }
                self.group.leave()
            })
            
            group.enter()
            MainDB.shared.getSimilarMoviesBy(movieId: movieId, page: 1, response: { (movies) in
                if let movies = movies {
                    self.similarMovies = movies
                }
                self.group.leave()
            })
            let resultGroupWait = group.wait(timeout: .now() + 30)
            if resultGroupWait == .success {
                self.tableView.reloadData()
            } else {
                #if DEBUG
                    print("time out")
                #endif
            }
            self.clearAllNotice()
            isFirstLoad = false
        }
    }
    
    func checkListMovies(cell: MovieDetailListTableCell, movieList: [Any]) {
        if movieList.count == 0  {
            cell.vNoResult.isHidden = false
            cell.collectionView.isHidden = true
        } else {
            cell.vNoResult.isHidden = true
            cell.collectionView.isHidden = false
        }
    }
    
    func continueAction(notification: Notification) {
        if let userInfo = notification.userInfo as? [String:Any] {
            if let videoId = userInfo["videoId"] as? Int {
//                isLogined = 1
//                addWatchList(videoId: videoId)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension MovieDetailViewController: AVPlayerViewControllerDelegate {
    func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        playerViewController.player?.play()
    }
    
    func playerViewControllerWillStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        playerViewController.player?.pause()
    }
}

extension MovieDetailViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieDetailCell", for: indexPath) as! MovieDetailTableCell
            guard let movie = self.movie else { return cell }
            cell.setupCell(movie: movie)
            cell.movie = movie
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieDetailListCell", for: indexPath) as! MovieDetailListTableCell
            
            checkListMovies(cell: cell, movieList: casts)
            
            cell.castList = casts
            cell.delegate = self
            cell.collectionView.reloadData()
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieDetailListCell", for: indexPath) as! MovieDetailListTableCell
            checkListMovies(cell: cell, movieList: recommendMovies)
            
            cell.movieList = recommendMovies
            cell.collectionView.reloadData()
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieDetailListCell", for: indexPath) as! MovieDetailListTableCell
            
            checkListMovies(cell: cell, movieList: similarMovies)
            cell.movieList = similarMovies
            cell.collectionView.reloadData()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return NSLocalizedString("h_cast", "")
        case 2:
            return NSLocalizedString("h_recommendations", "")
        case 3:
            return NSLocalizedString("h_similar", "")
        default:
            return nil
        }
    }
}

extension MovieDetailViewController: MovieDetailListTableCellDelegate {
    func moveToMoveListVCBy(castId: Int, castName: String) {
        let movieVC = self.storyboard?.instantiateViewController(withIdentifier: "MovieVC") as! MovieViewController
        movieVC.castId = castId
        movieVC.castName = castName
        self.navigationController?.pushViewController(movieVC, animated: true)
    }
}
