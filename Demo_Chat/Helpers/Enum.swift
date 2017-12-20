//
//  Enum.swift
//  Demo_Chat
//
//  Created by HungNV on 8/11/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import Foundation

enum MovieListTitle: String {
    case topRatedTitle = "h_top_rated"
    case popularTitle = "h_popular"
    case nowPlayingTitle = "h_now_playing"
    case upComingTitle = "h_upcoming"
}

enum TypeOfMovie: String {
    case topRated = "top_rated"
    case popular = "popular"
    case nowPlaying = "now_playing"
    case upComing = "upcoming"
}

enum TypeOfListMovieForCollectionViewInDetailTableViewCell {
    case CAST
    case RECOMMENDATION
    case SIMILAR
}

enum MusicDownloadState: UInt {
    case Avaiable = 0
    case Download
    case Downloaded
    case Delete
}
