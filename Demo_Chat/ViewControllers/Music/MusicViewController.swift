//
//  MusicViewController.swift
//  Demo_Chat
//
//  Created by HungNV on 8/8/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import Firebase

//var arrSong: [SongModel] = MainDB.shared.getSongModelDefault()
var arrSong: [MusicInfo] = [MusicInfo]()

class MusicViewController: BaseViewController {

    @IBOutlet weak var sldTime: UISlider!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnPrev: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblRunningTime: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imgViewBG: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var alphaView: UIView!
    @IBOutlet weak var lyricPlayerView: HCKaraokeLyricPlayerView!
    
    var avAudio: AVAudioPlayer!
    var timer: Timer!
    var position = 0
    
    var mask: CALayer?
    var songURL: URL?
    var lyric: HCKaraokeLyric?
    fileprivate var timingKeys: Array<CGFloat> = [CGFloat]()
    
    var isPlaying: Bool = false {
        didSet {
            self.changeButtonImage(isPlaying)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsHelper.shared.setGoogleAnalytic(name: kGAIScreenName, value: "music_screen")
        AnalyticsHelper.shared.setFirebaseAnalytic(screenName: "music_screen", screenClass: classForCoder.description())
    }
    
    func setupData() {
        LocalDB.shared().getMusicInLocalDB { (musics) in
            if let musics = musics {
                arrSong = musics
            }
        }
    }
    
    func refreshData() {
        LocalDB.shared().getMusicInLocalDB { (musics) in
            if let musics = musics {
                arrSong = musics
                self.position = 0
                self.collectionView.reloadData()
            }
        }
    }
    
    func setupView() {
        self.setupNavigation()
        alphaView.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(selectSong(_:)), name: NSNotification.Name(rawValue: kNotificationSelectSong), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name(rawValue: kNotificationRefreshDataMusic), object: nil)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            #if DEBUG
                print("Error audio session")
            #endif
        }
        self.lyricPlayerView.dataSource = self
        self.lyricPlayerView.delegate = self
    }
    
    func setupScreen() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        sldTime.minimumValue = 0
        self.getSong()
        sldTime.setThumbImage(#imageLiteral(resourceName: "circle_y"), for: UIControlState())
        avAudio.delegate = self
        
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.collectionView.isPagingEnabled = true
            layout.itemSize = CGSize(width: UIManager.screenWidth(), height: self.collectionView.bounds.height)
        }
    }
    
    func setupNavigation() {
        setupNavigationBar(vc: self, title: Define.shared.getNameMusicScreen().uppercased(), leftText: nil, leftImg: #imageLiteral(resourceName: "arrow_back"), leftSelector: #selector(self.actBack(btn:)), rightText: nil, rightImg: #imageLiteral(resourceName: "icon_search"), rightSelector: #selector(self.actSearch(btn:)), isDarkBackground: true, isTransparent: true)
    }
    
    func actBack(btn: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func actSearch(btn: UIButton) {
        let searchMusicVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchMusicVC") as! SearchMusicViewController
        self.navigationController?.pushViewController(searchMusicVC, animated: false)
    }
    
    func selectSong(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let position = userInfo["position"] as? Int {
                if position != self.position {
                    self.position = position
                    self.getSong()
                    self.actionPlaySong(false)
                } else {
                    self.actionPlaySong(avAudio.isPlaying)
                }
            }
        }
    }
    
    func getSong() {
        let first = arrSong[self.position]
        let fileMP3 = Helper.documentFolder() + "/\(first.urlJunDownload)"
        if let fileMP3URL = URL(string: fileMP3) {
            do {
                timingKeys = [CGFloat]()
                self.lyricPlayerView.stop()
                self.lyric = nil
                let lyricParser = HCBasicKaraokeLyricParser()
                self.lyric = lyricParser.lyricFromLocationPathFileName(lrcFileName: first.lyricsUrl)
                if let lyric = self.lyric, self.lyric?.content != nil {
                    timingKeys = Array(lyric.content!.keys).sorted(by: <)
                }
                avAudio = try AVAudioPlayer(contentsOf: fileMP3URL, fileTypeHint: "mp3")
                avAudio.delegate = self
                sldTime.value = 0
                sldTime.maximumValue = Float(avAudio.duration)
                let imgPath = Helper.documentFolder() + "/\(first.avatar)"
                imgViewBG.image = UIImage.init(contentsOfFile: imgPath)
                self.convertTimingToText(avAudio.currentTime, label: self.lblRunningTime)
                self.convertTimingToText(avAudio.duration, label: self.lblDuration)
            } catch {
                #if DEBUG
                    print("Error get song")
                #endif
            }
        }
    }

    func actionPlaySong(_ playing: Bool) {
        if timer != nil {
            timer.invalidate()
        }
        
        if playing {
            avAudio.pause()
            lyricPlayerView.pause()
            isPlaying = false
            
            AnalyticsHelper.shared.sendGoogleAnalytic(category: "music", action: "pause", label: "", value: nil)
            AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "music", action: "pause", label: "")
        } else {
            isPlaying = true
            avAudio.play()
            if self.lyric != nil {
                lyricPlayerView.start()
            } else {
                lyricPlayerView.stop()
            }
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(playingSong), userInfo: nil, repeats: true)
            
            AnalyticsHelper.shared.sendGoogleAnalytic(category: "music", action: "play", label: "", value: nil)
            AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "music", action: "play", label: "")
        }
        
        let userInfo: [AnyHashable: Any] = [
            "playing": playing,
            "currentTime": avAudio.currentTime,
            "position": self.position
        ]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationRotateImage), object: nil, userInfo: userInfo)
        self.setupBackgroundMode()
    }
    
    func convertTimingToText(_ time: Double, label: UILabel) {
        let minute = Int(time / 60)
        let seconds = Int(time - Double(minute * 60))
        self.setTimingSongForLabel(minute, seconds: seconds, label: label)
    }
    
    func setTimingSongForLabel(_ minute: Int, seconds: Int, label: UILabel) {
        let mStr = minute > 9 ? "\(minute)" : "0\(minute)"
        let sStr = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        label.text = "\(mStr):\(sStr)"
    }
    
    func changeButtonImage(_ playing: Bool) {
        if playing {
            btnPlay.setImage(#imageLiteral(resourceName: "ic_pause"), for: UIControlState())
        } else {
            btnPlay.setImage(#imageLiteral(resourceName: "ic_play"), for: UIControlState())
        }
    }
    
    func playingSong() {
        sldTime.value = Float(avAudio.currentTime)
        self.convertTimingToText(avAudio.currentTime, label: self.lblRunningTime)
    }
    
    func changeStatusPlaying(_ status: Bool) {
        let playing = arrSong[self.position]
        playing.isPlaying = status
        arrSong[self.position] = playing
    }
    
    func changeSong() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationChangeSong), object: nil, userInfo: ["position": self.position])
        self.getSong()
        self.actionPlaySong(false)
    }
    
    func playAtSelectedTime() {
        self.actionPlaySong(avAudio.isPlaying)
        let selectedTime = Double(sldTime.value)
        avAudio.currentTime = selectedTime
        if self.lyric != nil {
            lyricPlayerView.setCurrentTime(selectedTime)
        } else {
            lyricPlayerView.stop()
        }
        self.convertTimingToText(selectedTime, label: self.lblRunningTime)
        self.actionPlaySong(avAudio.isPlaying)
    }
    
    //MARK:- Main methods
    @IBAction func actPlaySong(_ sender: AnyObject) {
        if alphaView.isHidden {
            alphaView.isHidden = false
        }
        self.actionPlaySong(avAudio.isPlaying)
    }
    
    @IBAction func actNextSong(_ sender: AnyObject) {
        self.changeStatusPlaying(false)
        self.position += 1
        if self.position >= arrSong.count {
            self.position = 0
            self.changeStatusPlaying(true)
        }
        
        self.changeSong()
        
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "music", action: "next", label: "", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "music", action: "next", label: "")
    }
    
    @IBAction func actPervSong(_ sender: AnyObject) {
        self.changeStatusPlaying(false)
        self.position -= 1
        if self.position < 0 {
            self.position = arrSong.count - 1
            self.changeStatusPlaying(true)
        }
        
        self.changeSong()
        
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "music", action: "previous", label: "", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "music", action: "previous", label: "")
    }
    
    @IBAction func dragToTimeOfSong(_ sender: AnyObject) {
        Thread.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(playAtSelectedTime), with: nil, afterDelay: 0.2)
    }
    
    //MARK:- Event music in background
    func setupBackgroundMode() {
        let song = arrSong[self.position]
        let imgPath = Helper.documentFolder() + "/\(song.avatar)"
        let arr = MPMediaItemArtwork(image:  UIImage.init(contentsOfFile: imgPath)!)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: song.title,
            MPMediaItemPropertyArtist: song.artist,
            MPMediaItemPropertyArtwork: arr,
            MPMediaItemPropertyPlaybackDuration: avAudio.duration
        ]
        UIApplication.shared.beginReceivingRemoteControlEvents()
        becomeFirstResponder()
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        if let receivedEvent = event {
            if receivedEvent.type == .remoteControl {
                switch receivedEvent.subtype {
                case .remoteControlTogglePlayPause:
                    self.actionPlaySong(avAudio.isPlaying)
                    break
                case .remoteControlPlay:
                    self.actionPlaySong(false)
                    break
                case .remoteControlPause:
                    self.actionPlaySong(true)
                    break
                case .remoteControlNextTrack:
                    self.actNextSong(btnNext)
                    break
                case .remoteControlPreviousTrack:
                    self.actPervSong(btnPrev)
                default:
                    #if DEBUG
                        print("Received subtype \(receivedEvent.subtype) Ignoring")
                    #endif
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK:- UICollectionView
extension MusicViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SongCollectionCell.reuseIdentifier, for: indexPath) as! SongCollectionCell
            let song = arrSong[self.position]
            cell.songModel = song
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SongListCollectionCell.reuseIdentifier, for: indexPath) as! SongListCollectionCell
            if avAudio.isPlaying {
                cell.playingIndex = self.position
            }
            
            return cell
        }
    }
}

extension MusicViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        let indexImg = Int(offset / scrollView.bounds.size.width)
        
        pageControl.currentPage = indexImg
    }
}

//MARK:- Lyric karaoke
extension MusicViewController: HCLyricPlayerViewDataSource {
    func timesForLyricPlayerView(_ playerView: HCKaraokeLyricPlayerView) -> Array<CGFloat> {
        return timingKeys
    }
    
    func lyricPlayerView(_ playerView: HCKaraokeLyricPlayerView, atIndex: NSInteger) -> HCKaraokeLyricLabel {
        let lyricLabel = playerView.reuseLyricView()
        lyricLabel.textColor = UIColor.white
        lyricLabel.fillTextColor = Theme.shared.color_App()
        lyricLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
        
        let key = timingKeys[atIndex]
        lyricLabel.text = self.lyric?.content![key]
        
        return lyricLabel
    }
    
    func lyricPlayerView(_ playerView: HCKaraokeLyricPlayerView, allowLyricAnimationAtIndex: NSInteger) -> Bool {
        return true
    }
}

extension MusicViewController: HCLyricPlayerViewDelegate {
    func lyricPlayerViewDidStop(_ playerView: HCKaraokeLyricPlayerView) {
        timer?.invalidate()
    }
}

//MARK:- AVAudioPlayerDelegate
extension MusicViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            self.actNextSong(btnNext)
        }
    }
}
