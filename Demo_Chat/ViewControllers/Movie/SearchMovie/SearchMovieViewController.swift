//
//  SearchMovieViewController.swift
//  Demo_Chat
//
//  Created by HungNV on 8/16/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

class SearchMovieViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var movieList:[Movie] = [Movie]()
    var typeOfMovie:TypeOfMovie = .topRated
    var searchText:String = ""
    let searchController = UISearchController(searchResultsController: nil)
    
    var page = 1
    let refeshing = UIRefreshControl()
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    func setupView() {
        self.setupNavigation()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("h_search", "")
        searchController.searchBar.barTintColor = Theme.shared.color_Navigator()
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.setValue(NSLocalizedString("h_cancel", ""), forKey: "_cancelButtonText")
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.addSubview(refeshing)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func setupNavigation() {
        setupNavigationBar(vc: self, title: Define.shared.getNameSearchMovieScreen().uppercased(), leftText: nil, leftImg: #imageLiteral(resourceName: "arrow_back"), leftSelector: #selector(self.actBack(btn:)), rightText: nil, rightImg: nil, rightSelector: nil, isDarkBackground: true, isTransparent: true)
    }
    
    func actBack(btn: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func dataForNextPage() {
        Thread.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(loadNextPage), with: self, afterDelay: 0.2)
    }
    
    func loadNextPage() {
        page += 1
        isLoading = true
        
        MainDB.shared.searchMovie(searchText: searchText, page: page, response: { (movies) in
            if let movies = movies, movies.count > 0 {
                self.movieList += movies
                DispatchQueue.main.async(execute: { [weak self] in
                    guard let `self` = self else {return}
                    self.tableView.reloadData()
                    self.clearAllNotice()
                })
            } else {
                self.page -= 1
            }
            self.isLoading = false
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SearchMovieViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let textSearch:String = searchController.searchBar.text, textSearch.characters.count >= 1 {
            searchText = textSearch
            Thread.cancelPreviousPerformRequests(withTarget: self)
            self.perform(#selector(searchMovie), with: nil, afterDelay: TimeInterval(0.2))
        } else {
            searchText = ""
            self.movieList.removeAll()
            self.tableView.reloadData()
        }
    }
    
    func searchMovie() {
        if searchText == "" {return}
        self.pleaseWait()
        self.isLoading = true
        MainDB.shared.searchMovie(searchText: searchText, page: 1, response: { (movies) in
            if let movies = movies {
                self.movieList = movies
            }
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let `self` = self else {return}
                self.tableView.reloadData()
                self.clearAllNotice()
            })
            self.isLoading = false
        })
    }
}

extension SearchMovieViewController: UITableViewDataSource {
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

extension SearchMovieViewController: UITableViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isLoading { return }
        
        if refeshing.isRefreshing {
            self.searchMovie()
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
