//
//  MainDB.swift
//  Demo_Chat
//
//  Created by HungNV on 7/28/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import NCMB
import Alamofire

typealias JSONData = [String:Any]

class MainDB: NSObject {
    static let shared = MainDB()
    
    func getPushHistoryWithUserID(user_id: String, limit: Int32, skip: Int32, completionHandler: @escaping(Array<PushModel>) -> Void) {
        var results: Array<PushModel> = []
        
        let query = NCMBQuery.init(className: PUSH_CLASS)
        query?.whereKey("receive_id", equalTo: user_id)
        query?.limit = limit
        query?.skip = skip
        query?.order(byDescending: "createDate")
        query?.findObjectsInBackground({ (objects, error) in
            if error == nil {
                if let objects = objects as? Array<NCMBObject> {
                    if objects.count > 0 {
                        for obj:NCMBObject in objects {
                            if let push = PushModel(object: obj) {
                                results.append(push)
                            }
                        }
                    }
                }
            }
            
            completionHandler(results)
        })
    }
    
    //MARK:- Music
    func getSongModelDefault() -> Array<SongModel> {
        let songArr: [SongModel] = [
            SongModel(id: "0001", fileName: "AMN", type: "mp3", title: "Anh muốn nói", singer: "Trịnh Thăng Bình", isPlaying: false),
            SongModel(id: "0002", fileName: "CCNM", type: "mp3", title: "Cạn cả nước mắt", singer: "Karik, Thái Trinh", isPlaying: false),
            SongModel(id: "0003", fileName: "DM", type: "mp3", title: "Dấu mưa", singer: "Trung Quân Idol", isPlaying: false),
            SongModel(id: "0004", fileName: "ECDD", type: "mp3", title: "Em cứ đi đi", singer: "Vương Anh Tú", isPlaying: false),
            SongModel(id: "0005", fileName: "VTCS", type: "mp3", title: "Vì tôi còn sống", singer: "Tiên Tiên", isPlaying: false),
            SongModel(id: "0006", fileName: "TMW", type: "mp3", title: "Tell me why", singer: "Hoà Minzy", isPlaying: false),
            SongModel(id: "0007", fileName: "DADM", type: "mp3", title: "Đâu ai đợi mình", singer: "Trịnh Thăng Bình", isPlaying: false)
        ]
        
        return songArr
    }
    
    func searchMusic(searchText: String, hostName: String, responses: @escaping (_ musics:[Music]?)->()) {
        let searchHTML = searchText.html
        let param: [String:Any] = [
            "k" : searchHTML,
            "h" : hostName,
            "code" : MUSIC_API_KEY
        ]
        
        var musics: [Music] = [Music]()
        Alamofire.request("\(MUSIC_API)", method: .post, parameters: param)
            .responseJSON(queue: DispatchQueue.global(), completionHandler: { (response) in
                if let jsonDataList = response.result.value as? [JSONData], jsonDataList.count > 0 {
                    for jsonData in jsonDataList {
                        if let music = Music(jsonData: jsonData) {
                            musics.append(music)
                        }
                    }
                }
                responses(musics)
            })
    }
    
    //MARK:- Movie
    func getListMovie(page: Int, type: String, responses: @escaping(_ movies:[Movie]?) -> ()) {
        let param: [String:Any] = [
            "api_key" : V3_API_KEY,
            "language" : Define.shared.getLanguageMovie(),
            "page" : page
        ]
        
        var listMovie: [Movie] = [Movie]()
        Alamofire.request("\(V3_API_MOVIE)\(type)", method: .post, parameters: param)
            .responseJSON(queue: DispatchQueue.global(), completionHandler: { (response) in
                if let result = response.result.value as? JSONData {
                    if let jsonDataList = result["results"] as? [JSONData], jsonDataList.count > 0 {
                        for jsonData in jsonDataList {
                            if let movie = Movie(jsonData: jsonData) {
                                listMovie.append(movie)
                            }
                        }
                    }
                }
                responses(listMovie)
            })
    }
    
    func getMovieListBy(castId: Int, page: Int, response: @escaping (_ movies:[Movie]?) ->()) {
        var movies: [Movie] = [Movie]()
        Alamofire.request("\(V3_API)discover/movie?api_key=\(V3_API_KEY)&language=\(Define.shared.getLanguageMovie())&sort_by=vote_average.desc&include_adult=false&include_video=true&page=\(page)&primary_release_date.gte=2000-01-01&vote_average.gte=0&vote_average.lte=9.9&with_cast=\(castId)")
            .responseJSON(queue: DispatchQueue.global()) { (result) in
                
                if let response = result.result.value as? JSONData {
                    if let moviesData = response["results"] as? [JSONData], moviesData.count > 0 {
                        for movieData in moviesData {
                            if let movie = Movie(jsonData: movieData) {
                                movies.append(movie)
                            }
                        }
                    }
                }
                response(movies)
        }
    }
    
    //MARK:- GenreData
    var genreList: [Genre] = [Genre]()
    var isLoading = false
    
    func loadGenreList() {
        if isLoading {return}
        self.isLoading = true
        Alamofire.request("\(V3_API)genre/movie/list?api_key=\(V3_API_KEY)&language=\(Define.shared.getLanguageMovie())", method: .get)
            .responseJSON { (response) in
                if let resultData = response.result.value as? JSONData {
                    if let genresData = resultData["genres"] as? [JSONData], genresData.count > 0 {
                        self.genreList.removeAll()
                        for genreData in genresData {
                            if let genre = Genre(jsonData: genreData) {
                                self.genreList.append(genre)
                            }
                        }
                    }
                }
                self.isLoading = false
        }
    }
    
    func getDictionFromGenreList() -> [Int:String] {
        var dicGenre:[Int:String] = [Int:String]()
        
        if genreList.count <= 0 {return dicGenre}
        
        for genre in genreList {
            dicGenre[genre.id] = genre.name
        }
        return dicGenre
    }
    
    //MARK:- MovieDetail
    func movieDetail(id: Int, response: @escaping (_ movie: MovieDetail?) -> () ) {
        Alamofire.request("\(V3_API_MOVIE)\(id)?api_key=\(V3_API_KEY)&language=\(Define.shared.getLanguageMovie())", method: .get)
            .responseJSON(queue: DispatchQueue.global()) { (resultJSON) in
                var detail:MovieDetail?
                if let result = resultJSON.result.value as? JSONData {
                    if let movieDetail = MovieDetail(jsonData: result) {
                        detail = movieDetail
                    }
                }
                response(detail)
        }
    }
    
    func getVideosByMovieId(id: Int, response: @escaping (_ videos: [Video]?) -> () ) {
        var videos: [Video] = [Video]()
        Alamofire.request("\(V3_API_MOVIE)\(id)/videos?api_key=\(V3_API_KEY)&language=en-US", method: .get)
            .responseJSON(queue: DispatchQueue.global()) { (resultJSON) in
                if let response = resultJSON.result.value as? JSONData {
                    if let videosData = response["results"] as? [JSONData], videosData.count > 0 {
                        for videoData in videosData {
                            if let video = Video(jsonData: videoData) {
                                videos.append(video)
                            }
                        }
                    }
                    
                }
                response(videos)
        }
    }
    
    func getCastListBy(movieId: Int, page: Int, response: @escaping (_ movies:[Cast]?) -> ()) {
        var castList: [Cast] = [Cast]()
        Alamofire.request("\(V3_API_MOVIE)\(movieId)/credits?api_key=\(V3_API_KEY)&language=\(Define.shared.getLanguageMovie())&page=\(page)")
            .responseJSON(queue: DispatchQueue.global()) { (result) in
                if let response = result.result.value as? JSONData {
                    if let castListData = response["cast"] as? [JSONData], castListData.count > 0 {
                        for castData in castListData {
                            if let cast = Cast(jsonData: castData) {
                                castList.append(cast)
                            }
                        }
                    }
                }
                response(castList)
        }
    }
    
    func getRecommendMoviesBy(movieId: Int, page: Int, response: @escaping (_ movies:[Movie]?) -> ()) {
        var movies:[Movie] = [Movie]()
        Alamofire.request("\(V3_API_MOVIE)\(movieId)/recommendations?api_key=\(V3_API_KEY)&language=\(Define.shared.getLanguageMovie())&include_adult=true&page=\(page)")
            .responseJSON(queue: DispatchQueue.global()) { (result) in
                if let response = result.result.value as? JSONData {
                    if let moviesData = response["results"] as? [JSONData], moviesData.count > 0 {
                        for movieData in moviesData {
                            if let movie = Movie(jsonData: movieData) {
                                movies.append(movie)
                            }
                        }
                    }
                }
                response(movies)
        }
    }
    
    func getSimilarMoviesBy(movieId: Int, page: Int, response: @escaping (_ movies:[Movie]?)->()) {
        var movies:[Movie] = [Movie]()
        Alamofire.request("\(V3_API_MOVIE)\(movieId)/similar?api_key=\(V3_API_KEY)&language=\(Define.shared.getLanguageMovie())&include_adult=true&page=\(page)")
            .responseJSON(queue: DispatchQueue.global()) { (result) in
                if let response = result.result.value as? JSONData {
                    if let moviesData = response["results"] as? [JSONData], moviesData.count > 0 {
                        for movieData in moviesData {
                            if let movie = Movie(jsonData: movieData) {
                                movies.append(movie)
                            }
                        }
                    }
                }
                response(movies)
        }
    }
    
    func searchMovie(searchText: String, page: Int, response: @escaping (_ movies:[Movie]?)->()) {
        let searchHTML = searchText.html
        var movies: [Movie] = [Movie]()
        Alamofire.request("\(V3_API)search/multi?api_key=\(V3_API_KEY)&language=\(Define.shared.getLanguageMovie())&query=\(searchHTML)&include_adult=false&page=\(page)")
            .responseJSON(queue: DispatchQueue.global()) { (result) in
                if let response = result.result.value as? JSONData {
                    if let moviesData = response["results"] as? [JSONData], moviesData.count > 0 {
                        for movieData in moviesData {
                            if let movie = Movie(jsonData: movieData) {
                                movies.append(movie)
                            }
                        }
                    }
                }
                response(movies)
        }
    }
    
    //MARK:- App
    func getAllApplicationClass(completionHandler: @escaping(Array<ApplicationModel>) -> Void) {
        var results: Array<ApplicationModel> = []
        
        let query = NCMBQuery.init(className: APPLICATION_CLASS)
        query?.order(byDescending: "release_date")
        query?.findObjectsInBackground({ (objects, error) in
            if error == nil {
                if let objects = objects as? Array<NCMBObject> {
                    if objects.count > 0 {
                        for obj:NCMBObject in objects {
                            if let app = ApplicationModel(object: obj) {
                                results.append(app)
                            }
                        }
                    }
                }
            }
            
            completionHandler(results)
        })
    }
}
