//
//  SearchMusicViewController.swift
//  Demo_Chat
//
//  Created by HungNV on 8/29/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import EZAlertController

class SearchMusicViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnDownloadMusic: UIButton!
    
    var musicList: [Music] = [Music]()
    var searchText: String = ""
    let searchController = UISearchController(searchResultsController: nil)
    let group = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    func setupView() {
        self.setupNavigation()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.placeholder = NSLocalizedString("h_search", "")
        searchController.searchBar.barTintColor = Theme.shared.color_Navigator()
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.setValue(NSLocalizedString("h_cancel", ""), forKey: "_cancelButtonText")
        searchController.searchBar.scopeButtonTitles = [HOST_NHAC_CUA_TUI, HOST_MP3_ZING]
        searchController.searchBar.delegate = self
        tableView.tableHeaderView = searchController.searchBar
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableViewAutomaticDimension
        
        btnDownloadMusic.layer.cornerRadius = btnDownloadMusic.frame.size.height / 2
        btnDownloadMusic.clipsToBounds = true
    }
    
    func setupNavigation() {
        setupNavigationBar(vc: self, title: Define.shared.getNameSearchMusicScreen().uppercased(), leftText: nil, leftImg: #imageLiteral(resourceName: "arrow_back"), leftSelector: #selector(self.actBack(btn:)), rightText: nil, rightImg: nil, rightSelector: nil, isDarkBackground: true, isTransparent: true)
    }
    
    func actBack(btn: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actDownloadMusic(_ sender: Any) {
        var arrayDownload: [Music] = [Music]()
        for music in musicList {
            if music.musicDownloadState == .Download {
                arrayDownload.append(music)
            }
        }
        
        if arrayDownload.count > 0 {
            //Download
            self.pleaseWait()
            for music in arrayDownload {
                //Image
                group.enter()
                DownloadHelper.shared.downloadImageWithURL(urlStr: music.avatar, filename: "\(music.id).jpg", completionHandler: { (success) in
                    if success {
                        //File mp3
                        DownloadHelper.shared.downloadFileMP3WithURL(urlStr: music.urlJunDownload, filename: "\(music.id).mp3", completionHandler: { (success) in
                            if success {
                                //Save db
                                LocalDB.shared().addMusicInLocalDB(obj: music, response: { (success) in
                                    if success {
                                        self.group.leave()
                                    }
                                })
                            }
                        })
                    }
                })
            }
            
            group.notify(queue: DispatchQueue.main) {
                arrayDownload.removeAll()
                self.clearAllNotice()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationRefreshDataMusic), object: nil, userInfo: nil)
                EZAlertController.alert(kAppName, message: NSLocalizedString("h_download_music_finished", ""))
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SearchMusicViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let textSearch:String = searchController.searchBar.text, textSearch.characters.count >= 1 {
            searchText = textSearch
            guard let hostName = searchController.searchBar.scopeButtonTitles?[searchController.searchBar.selectedScopeButtonIndex] else { return }
            Thread.cancelPreviousPerformRequests(withTarget: self)
            self.perform(#selector(searchMusic(_:)), with: hostName, afterDelay: TimeInterval(0.2))
        } else {
            searchText = ""
            self.musicList.removeAll()
            self.tableView.reloadData()
        }
    }
    
    func searchMusic(_ hostName: String) {
        if searchText == "" {return}
        self.pleaseWait()
        MainDB.shared.searchMusic(searchText: searchText, hostName: hostName, responses: { (musics) in
            if let musics = musics {
                self.musicList = musics
            }
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let `self` = self else {return}
                self.tableView.reloadData()
                self.clearAllNotice()
            })
        })
    }
}

extension SearchMusicViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let hostName = searchController.searchBar.scopeButtonTitles?[searchController.searchBar.selectedScopeButtonIndex] else { return }
        self.searchMusic(hostName)
    }
}

extension SearchMusicViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
        let music = musicList[indexPath.row]
        cell.configCell(music: music)
        
        return cell
    }
}

extension SearchMusicViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var music = musicList[indexPath.row]
        
        switch music.musicDownloadState {
        case .Avaiable:
            music.musicDownloadState = .Download
            break
            
        case .Download:
            music.musicDownloadState = .Avaiable
            break
            
        case .Downloaded:
            music.musicDownloadState = .Delete
            break
            
        case .Delete:
            music.musicDownloadState = .Downloaded
            break
        }
        musicList[indexPath.row] = music
        
        let cell = tableView.cellForRow(at: indexPath) as! SearchCell
        cell.updateStatus(music: music)
    }
}
