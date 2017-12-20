//
//  PageMenuViewController.swift
//  Demo_Chat
//
//  Created by HungNV on 8/11/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import Alamofire

class PageMenuViewController: BaseViewController {

    @IBOutlet weak var containerView: UIView!
    var pageMenu: HCPageMenu!
    let group = DispatchGroup()
    var topRatedMovieList: [Movie] = [Movie]()
    var popularMovieList: [Movie] = [Movie]()
    var nowPlayingMovieList: [Movie] = [Movie]()
    var upComingMovieList: [Movie] = [Movie]()
    var searchController: UISearchController!
    
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
        self.setupData()
    }
    
    func setupView() {
        self.setupNavigation()
        NotificationCenter.default.addObserver(self, selector: #selector(moveToDetailVCBy(_:)), name: NSNotification.Name(rawValue: kNotificationMovieDetail), object: nil)
    }
    
    func setupData() {
        if isFirstLoad {
            self.pleaseWait()
            group.enter()
            MainDB.shared.getListMovie(page: page, type: TypeOfMovie.topRated.rawValue, responses: { (movieList) in
                if let `movieList` = movieList {
                    self.topRatedMovieList = movieList
                    self.group.leave()
                }
            })
            
            group.enter()
            MainDB.shared.getListMovie(page: page, type: TypeOfMovie.popular.rawValue, responses: { (movieList) in
                if let `movieList` = movieList {
                    self.popularMovieList = movieList
                    self.group.leave()
                }
            })
            
            group.enter()
            MainDB.shared.getListMovie(page: page, type: TypeOfMovie.nowPlaying.rawValue, responses: { (movieList) in
                if let `movieList` = movieList {
                    self.nowPlayingMovieList = movieList
                    self.group.leave()
                }
            })
            
            group.enter()
            MainDB.shared.getListMovie(page: page, type: TypeOfMovie.upComing.rawValue, responses: { (movieList) in
                if let `movieList` = movieList {
                    self.upComingMovieList = movieList
                    self.group.leave()
                }
            })
            
            let timeout = group.wait(timeout: .now() + 30)
            if timeout == .success {}
            group.notify(queue: DispatchQueue.main) {
                self.clearAllNotice()
            }
            
            self.createPageMenu()
            isFirstLoad = false
        }
    }
    
    func setupNavigation() {
        setupNavigationBar(vc: self, title: Define.shared.getNameMovieScreen().uppercased(), leftText: nil, leftImg: #imageLiteral(resourceName: "arrow_back"), leftSelector: #selector(self.actBack(btn:)), rightText: nil, rightImg: #imageLiteral(resourceName: "icon_search"), rightSelector: #selector(self.actSearch(btn:)), isDarkBackground: true, isTransparent: true)
    }
    
    func actBack(btn: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func actSearch(btn: UIButton) {
        let searchMovieVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchMovieVC") as! SearchMovieViewController
        self.navigationController?.pushViewController(searchMovieVC, animated: false)
    }
    
    func createPageMenu() {
        let topRatedVC = self.createViewControllerForPageMenu(titleType: .topRatedTitle)
        let popularVC = self.createViewControllerForPageMenu(titleType: .popularTitle)
        let nowPlayingVC = self.createViewControllerForPageMenu(titleType: .nowPlayingTitle)
        let upComingVC = self.createViewControllerForPageMenu(titleType: .upComingTitle)
        
        let parameters: [HCPageMenuOption] = [
            .UnselectedMenuItemLabelColor(UIColor.white),
            .ScrollMenuBackgroundColor(Theme.shared.color_Navigator()),
            .ViewBackgroundColor(UIColor.white),
            .SelectionIndicatorColor(Theme.shared.color_BottonScroll()),
            .MenuItemFont(Theme.shared.font_primaryRegular(size: .small)),
            .MenuHeight(40.0),
            .CenterMenuItems(true)
        ]
        
        pageMenu = HCPageMenu(viewControllers: [topRatedVC, popularVC, nowPlayingVC, upComingVC], frame: CGRect(x: 0.0,y: 20 + (self.navigationController?.navigationBar.bounds.size.height)!, width: kScreenWidth, height: kScreenHeight - 64), pageMenuOptions: parameters)
        containerView.addSubview(pageMenu!.view)
        pageMenu.didMove(toParentViewController: self)
    }
    
    func createViewControllerForPageMenu(titleType: MovieListTitle) -> MovieViewController {
        let movieVC = self.storyboard?.instantiateViewController(withIdentifier: "MovieVC") as! MovieViewController
        movieVC.title = NSLocalizedString("\(titleType.rawValue)", "")
        
        switch titleType {
        case .topRatedTitle:
            movieVC.movieList = topRatedMovieList
            movieVC.typeOfMovie = .topRated
        case .popularTitle:
            movieVC.movieList = popularMovieList
            movieVC.typeOfMovie = .popular
        case .nowPlayingTitle:
            movieVC.movieList = nowPlayingMovieList
            movieVC.typeOfMovie = .nowPlaying
        default:
            movieVC.movieList = upComingMovieList
            movieVC.typeOfMovie = .upComing
        }
        
        return movieVC
    }

    func moveToDetailVCBy(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {return}
        guard let movieId = userInfo["movieId"] as? Int else {return}
        
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetailVC") as! MovieDetailViewController
        detailVC.movieId = movieId
        self.navigationController?.pushViewController(detailVC, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
