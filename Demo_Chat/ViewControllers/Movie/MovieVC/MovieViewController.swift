//
//  MovieViewController.swift
//  Demo_Chat
//
//  Created by HungNV on 8/11/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

class MovieViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    var movieList:[Movie] = [Movie]()
    var typeOfMovie:TypeOfMovie?
    var castId:Int?
    var castName: String = ""
    
    var page = 1
    var isFirstLoad = true
    let refeshing = UIRefreshControl()
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstLoad {
            if let _ = self.castId {
                self.pleaseWait()
                self.title = castName
                self.dataForFirstPage()
            }
            
            isFirstLoad = false
        }
    }
    
    func setupView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.addSubview(refeshing)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func dataForFirstPage() {
        page = 1
        isLoading = true
        if let typeOfMovie = typeOfMovie {
            MainDB.shared.getListMovie(page: page, type: typeOfMovie.rawValue) { (movieList) in
                if let movieList = movieList {
                    self.movieList = movieList
                    DispatchQueue.main.async(execute: { [weak self] in
                        guard let `self` = self else {return}
                        self.tableView.reloadData()
                    })
                }
                self.isLoading = false
                self.clearAllNotice()
            }
        } else {
            guard let castId = self.castId else { return }
            MainDB.shared.getMovieListBy(castId: castId, page: page, response: { (movies) in
                if let movies = movies {
                    self.movieList = movies
                    DispatchQueue.main.async(execute: { [weak self] in
                        guard let `self` = self else {return}
                        self.tableView.reloadData()
                    })
                    
                }
                self.isLoading = false
                self.clearAllNotice()
            })
        }
    }
    
    func dataForNextPage() {
        Thread.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(loadNextPage), with: self, afterDelay: 0.2)
    }
    
    func loadNextPage() {
        page += 1
        isLoading = true
        if let typeOfMovie = typeOfMovie {
            MainDB.shared.getListMovie(page: page, type: typeOfMovie.rawValue) { (movieList) in
                if let movieList = movieList, movieList.count > 0 {
                    self.movieList += movieList
                    DispatchQueue.main.async(execute: { [weak self] in
                        guard let `self` = self else {return}
                        self.tableView.reloadData()
                    })
                } else {
                    self.page -= 1
                }
                self.isLoading = false
            }
        } else {
            guard let castId = self.castId else { return }
            MainDB.shared.getMovieListBy(castId: castId, page: page, response: { (movies) in
                if let movies = movies, movies.count > 0 {
                    self.movieList += movies
                    DispatchQueue.main.async(execute: { [weak self] in
                        guard let `self` = self else {return}
                        self.tableView.reloadData()
                    })
                } else {
                    self.page -= 1
                }
                self.isLoading = false
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension MovieViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = movieList[indexPath.row]
        cell.configCell(movie: movie)
        
        return cell
    }
}

extension MovieViewController: UITableViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isLoading { return }
        
        if refeshing.isRefreshing {
            self.dataForFirstPage()
            refeshing.endRefreshing()
        }
        
        let offSetY = scrollView.contentOffset.y
        let heightOfContent = scrollView.contentSize.height
        
        if heightOfContent - offSetY - scrollView.bounds.size.height <= 1 {
            self.dataForNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = movieList[indexPath.item]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationMovieDetail), object: nil, userInfo: ["movieId": movie.id])
    }
}
