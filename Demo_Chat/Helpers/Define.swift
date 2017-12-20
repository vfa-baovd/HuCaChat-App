//
//  Define.swift
//  Demo_Chat
//
//  Created by Nguyen Van Hung on 2/5/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import Foundation

let GENERAL_CHANNEL_KEY = "-KJn8UTbJq2yWEnqum3K"

public let kScreenWidth = UIScreen.main.bounds.width
public let kScreenHeight = UIScreen.main.bounds.height

public let kUserInfo = "kUserInfo"
public let kAllowLocation = "kAllowLocation"
public let kCopyMusicToDocument = "kCopyMusicToDocument"
public let kLastVersion = "kLastVersion"
public let kShowAdMod = "kShowAdMod"
public let TYPE_PUSH_CHAT = "PushChat"
public let NUM_LIMIT: UInt = 25
public let V3_API = "https://api.themoviedb.org/3/"
public let V3_API_MOVIE = "\(V3_API)movie/"
public let V4_API = "https://api.themoviedb.org/4/"
public let IMAGE_API = "https://image.tmdb.org/t/p/"
public let BACKDROP_SIZE_KEY = "w780"
public let BACKDROP_SIZE: CGFloat = 780
public let LOGO_SIZE_KEY = "w500"
public let LOGO_SIZE: CGFloat = 500
public let POSTER_SIZE_KEY = "w500"
public let POSTER_SIZE: CGFloat = 500
public let PROFILE_SIZE_KEY = "w185"
public let PROFILE_SIZE = 185
public let STILL_SIZE_KEY = "w300"
public let STILL_SIZE: CGFloat = 300
public let VIDEO_API = "https://www.youtube.com/"
public let HOST_TEST_NETWORK = "www.apple.com"
public let MUSIC_API = "http://j.ginggong.com/jOut.ashx"
public let HOST_MP3_ZING = "mp3.zing.vn"
public let HOST_NHAC_CUA_TUI = "nhaccuatui.com"

#if CHATDEV
    public let kAppName = "Demo_Chat"
    public let GOOGLE_SERVER_FILE_NAME = "GoogleService-Info"
    public let URL_SCHEME_FACEBOOK = "fb1908408409431334"
    
    public let CONSUMER_KEY = "KfpKk4cV0WqMvAFXUiL7N6127"
    public let CONSUMER_SECRET = "L9EUgdRX0WXi9qcnoMrUhz3iIyYWNgWC7VAYv0ZlfZGRhAkoPG"
    public let URL_SCHEME_TWITTER = "twitterkit-KfpKk4cV0WqMvAFXUiL7N6127"
    
    public let TRACKING_ID = "UA-65691348-2"
    
    public let AD_UNIT_ID_FOR_BANNER_TEST = "ca-app-pub-3940256099942544/2934735716"
    
    public let MBAAS_APP_KEY = "699ae47a9acf9f0d348620e6c98da33c42e345949a1412350c7322a055abf5a7"
    public let MBAAS_CLIENT_KEY = "027d8cff41a640090328d2061cb5843c67987c4f7aae66bb01cd20d0f1036a2a"
    
    public let MAP_KEY = "AIzaSyAUTyfUjqSiCuH-BWzxchSrmmJ1LvMatFk"
    public let SERVER_URL = "https://hucachat.herokuapp.com/"
    
    public let V3_API_KEY = "fe015b73317057306ca44166e3f19bbb"
    public let V4_API_KEY = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmZTAxNWI3MzMxNzA1NzMwNmNhNDQxNjZlM2YxOWJiYiIsInN1YiI6IjU4M2VjMTdhOTI1MTQxMTUyZDAwOTdiYyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ._8x5fxbJgCk3YC6e9Qef8_3DpH2G3oaxsLvDi7la8Y4"
    
    public let MUSIC_API_KEY = "0ecb4522-6cfc-4421-92b5-e316b9054f29"
#else
    public let kAppName = "HuCaChat"
    public let GOOGLE_SERVER_FILE_NAME = "GoogleService-Info-Real"
    public let URL_SCHEME_FACEBOOK = "fb1908408409431334"
    
    public let CONSUMER_KEY = "KfpKk4cV0WqMvAFXUiL7N6127"
    public let CONSUMER_SECRET = "L9EUgdRX0WXi9qcnoMrUhz3iIyYWNgWC7VAYv0ZlfZGRhAkoPG"
    public let URL_SCHEME_TWITTER = "twitterkit-KfpKk4cV0WqMvAFXUiL7N6127"
    
    public let TRACKING_ID = "UA-70915177-2"
    
    public let AD_UNIT_ID_FOR_BANNER_TEST = "ca-app-pub-8391716737248301/3412485571"
    
    public let MBAAS_APP_KEY = "16d22b4242aabdae551b28c3fe4ba7fd7a14aeb2afa176c80d272dc162cd821b"
    public let MBAAS_CLIENT_KEY = "e8de7b7bf85b894b1da1c8b0a814f585da4c3fdc602f83dca96f7c6163c3063a"
    
    public let MAP_KEY = "AIzaSyC1_VVI7_2W4Fa-l4xsHEev93dkcz3DC5o"
    public let SERVER_URL = "https://hucachat.herokuapp.com/"
    
    public let V3_API_KEY = "fe015b73317057306ca44166e3f19bbb"
    public let V4_API_KEY = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmZTAxNWI3MzMxNzA1NzMwNmNhNDQxNjZlM2YxOWJiYiIsInN1YiI6IjU4M2VjMTdhOTI1MTQxMTUyZDAwOTdiYyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ._8x5fxbJgCk3YC6e9Qef8_3DpH2G3oaxsLvDi7la8Y4"
    
    public let MUSIC_API_KEY = "0ecb4522-6cfc-4421-92b5-e316b9054f29"
#endif

//Class mBass
public let PUSH_CLASS = "PushClass"
public let APPLICATION_CLASS = "ApplicationClass"

//Notification
public let kNotificationShowMessage = "key_notification_show_message"
public let kNotificationRefreshData = "key_notification_refresh_data"
public let kNotificationRotateImage = "key_notification_rotate_image"
public let kNotificationChangeSong  = "key_notification_change_song"
public let kNotificationContinueRotate = "key_notification_continue_rotate"
public let kNotificationSelectSong     = "key_notification_select_song"
public let kNotificationMovieDetail    = "key_notification_movie_detail"
public let kNotificationReachable      = "key_notification_reachable"
public let kNotificationNotReachable   = "key_notification_not_reachable"
public let kNotificationRefreshLanguage = "key_notification_refresh_language"
public let kNotificationPrivateLocation = "key_notification_private_location"
public let kNotificationRefreshDataMusic = "key_notification_refresh_data_music"

//Language
public let LANGUAGE_KEY = "language_key"
public let LANGUAGE_CODE_AUTO = "auto"
public let LANGUAGE_CODE_EN = "en"
public let LANGUAGE_CODE_VI = "vi"
public let LANGUAGE_CODE_JA = "ja"

class Define: NSObject {
    static let shared = Define()
    
    fileprivate override init() {
        super.init()
    }
    
    func getGeneralChannelKey() -> String {
        return GENERAL_CHANNEL_KEY
    }
    
    func getLanguageMovie() -> String {
        return NSLocalizedString("h_movie_language_API", "");
    }
    
    func getTitleMessageTemplate() -> String {
        return NSLocalizedString("h_message_from", "")
    }
    
    func getNameHomeScreen() -> String {
        return NSLocalizedString("h_chats", "")
    }
    
    func getNameContactScreen() -> String {
        return NSLocalizedString("h_contact", "")
    }
    
    func getNameGroupScreen() -> String {
        return NSLocalizedString("h_group", "")
    }
    
    func getNameCreateGroupScreen() -> String {
        return NSLocalizedString("h_create_group", "")
    }
    
    func getNameAddUsersScreen() -> String {
        return NSLocalizedString("h_add_users", "")
    }
    
    func getNameNotificationScreen() -> String {
        return NSLocalizedString("h_notifications", "")
    }
    
    func getNameMoreScreen() -> String {
        return NSLocalizedString("h_more", "")
    }
    
    func getNameStatusMessageScreen() -> String {
        return NSLocalizedString("h_status_message", "")
    }
    
    func getNameChatSettingsScreen() -> String {
        return NSLocalizedString("h_chat_settings", "")
    }
    
    func getNameBlockUsersScreen() -> String {
        return NSLocalizedString("h_blocked_users", "")
    }
    
    func getNameDetailImageScreen() -> String {
        return NSLocalizedString("h_detail_image", "")
    }
    
    func getNameMapScreen() -> String {
        return NSLocalizedString("h_map", "")
    }
    
    func getNameMusicScreen() -> String {
        return NSLocalizedString("h_music", "")
    }
    
    func getNameSearchMusicScreen() -> String {
        return NSLocalizedString("h_search_music", "")
    }
    
    func getNameMovieScreen() -> String {
        return NSLocalizedString("h_movie", "")
    }
    
    func getNameDetailMovieScreen() -> String {
        return NSLocalizedString("h_now_playing", "")
    }
    
    func getNameSearchMovieScreen() -> String {
        return NSLocalizedString("h_search_movie", "")
    }
    
    func getNameAboutScreen() -> String {
        return NSLocalizedString("h_app_game_of_developer", "")
    }
}
