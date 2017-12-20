//
//  HCKaraokeLyricPlayerView.swift
//  Demo_Chat
//
//  Created by HungNV on 8/8/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

let kHCLyricPlayerPadding: CGFloat = 8.0

@objc protocol HCLyricPlayerViewDataSource: class {
    func timesForLyricPlayerView(_ playerView: HCKaraokeLyricPlayerView) -> Array<CGFloat>
    func lyricPlayerView(_ playerView: HCKaraokeLyricPlayerView, atIndex: NSInteger) -> HCKaraokeLyricLabel
    @objc optional func lengthOfLyricPlayerView(_ playerView: HCKaraokeLyricPlayerView) -> CFTimeInterval
    func lyricPlayerView(_ playerView: HCKaraokeLyricPlayerView, allowLyricAnimationAtIndex: NSInteger) -> Bool
}

@objc protocol HCLyricPlayerViewDelegate: class {
    @objc optional func lyricPlayerViewDidStart(_ playerView: HCKaraokeLyricPlayerView)
    @objc optional func lyricPlayerViewDidStop(_ playerView: HCKaraokeLyricPlayerView)
}

enum HCPlayerLyricPosition: Int {
    case top, bottom
}

class HCKaraokeLyricPlayerView: UIView {
    weak var dataSource: HCLyricPlayerViewDataSource?
    weak var delegate: HCLyricPlayerViewDelegate?
    
    var isPlaying: Bool = false
    
    fileprivate var timer: Timer?
    fileprivate var currentPlayTime: CFTimeInterval = 0
    fileprivate var length: CFTimeInterval = 0
    fileprivate var lyricTop: HCKaraokeLyricLabel!
    fileprivate var lyricBottom: HCKaraokeLyricLabel!
    fileprivate var nextLabelHaveToUpdate: HCPlayerLyricPosition = HCPlayerLyricPosition.top
    
    fileprivate var indexTiming: NSInteger = 0
    fileprivate var timeIntervalRemain: CFTimeInterval = 0
    fileprivate var timingForLyric: Array<CGFloat> = [CGFloat]()
    
    //MARK:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        currentPlayTime = 0.0
        length = 0.0
        timingForLyric = [CGFloat]()
        indexTiming = 0
        isPlaying = false
        nextLabelHaveToUpdate = .top
    }
    
    func setupLabels() {
        lyricTop = HCKaraokeLyricLabel()
        lyricBottom = HCKaraokeLyricLabel()
        
        self.addSubview(lyricTop)
        self.addSubview(lyricBottom)
        
        self.setupLabelConstraintsForPosition(.top)
        self.setupLabelConstraintsForPosition(.bottom)
    }
    
    //MARK:- Helper methods
    fileprivate func setupLabelConstraintsForPosition(_ pos: HCPlayerLyricPosition) {
        let views: Dictionary<String, UIView> = ["lyricTop": lyricTop, "lyricBottom": lyricBottom]
        let metrics: Dictionary<String, CGFloat> = ["topMargin": kHCLyricPlayerPadding, "bottomMargin": kHCLyricPlayerPadding]
        
        if pos == .top {
            lyricTop.translatesAutoresizingMaskIntoConstraints = false
            let vTop = NSLayoutConstraint.constraints(withVisualFormat: "V:|-topMargin-[lyricTop]", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
            
            let centerX = NSLayoutConstraint(item: lyricTop, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
            
            self.addConstraints(vTop)
            self.addConstraint(centerX)
        }
        
        if pos == .bottom {
            lyricBottom.translatesAutoresizingMaskIntoConstraints = false
            let vBottom = NSLayoutConstraint.constraints(withVisualFormat: "V:[lyricBottom]-bottomMargin-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
            
            let centerX = NSLayoutConstraint(item: lyricBottom, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
            
            self.addConstraints(vBottom)
            self.addConstraint(centerX)
        }
    }
    
    func isLastLyric() -> Bool {
        return indexTiming >= (timingForLyric.count - 1)
    }
    
    func calculateDurationForLyricLabel() -> CGFloat {
        var duration: CGFloat = 0.0
        
        if !isLastLyric() {
            let timing = timingForLyric[indexTiming]
            let nextTiming = timingForLyric[indexTiming + 1]
            duration = nextTiming - timing
        }
        
        return duration
    }
    
    fileprivate func showNextLabel() {
        if indexTiming >= timingForLyric.count {
            return
        }
        
        var lyricLabel: HCKaraokeLyricLabel!
        if let dataSource = self.dataSource {
            lyricLabel = dataSource.lyricPlayerView(self, atIndex: indexTiming)
            if lyricLabel !== lyricTop && lyricLabel !== lyricBottom {
                if nextLabelHaveToUpdate == .top {
                    lyricTop = lyricLabel
                    self.addSubview(lyricTop)
                    self.setupLabelConstraintsForPosition(.top)
                } else {
                    lyricBottom = lyricLabel
                    self.addSubview(lyricBottom)
                    self.setupLabelConstraintsForPosition(.bottom)
                }
                
                nextLabelHaveToUpdate = (nextLabelHaveToUpdate == .top) ? .bottom : .top
            }
        } else {
            lyricLabel = self.reuseLyricView()
        }
        
        lyricLabel.reset()
        lyricLabel.duration = self.calculateDurationForLyricLabel()
    }
    
    //MARK:- Main methods
    func reuseLyricView() -> HCKaraokeLyricLabel {
        let reusedView = (nextLabelHaveToUpdate == .top) ? lyricTop : lyricBottom
        nextLabelHaveToUpdate = (nextLabelHaveToUpdate == .top) ? .bottom : .top
        
        return reusedView!
    }
    
    func handleAnimationAndShowLabel(_ timer: Timer) {
        var isAllowedAnimation = true
        
        if let dataSource = self.dataSource {
            isAllowedAnimation = dataSource.lyricPlayerView(self, allowLyricAnimationAtIndex: indexTiming)
        }
        
        let lyricWillAnimate = (nextLabelHaveToUpdate == .top) ? lyricBottom : lyricTop
        
        if isAllowedAnimation && !(lyricWillAnimate?.text!.isEmpty)! {
            lyricWillAnimate?.startAnimation()
        }
        
        if isLastLyric() == false {
            let timing = TimeInterval(self.calculateDurationForLyricLabel())
            
            self.timer = Timer.scheduledTimer(timeInterval: timing, target: self, selector: #selector(handleAnimationAndShowLabel(_:)), userInfo: nil, repeats: false)
            indexTiming += 1
            self.showNextLabel()
        } else {
            isPlaying = false
            self.delegate?.lyricPlayerViewDidStop?(self)
        }
    }
    
    func prepareToPlay() {
        self.setup()
        
        if lyricTop == nil || lyricBottom == nil {
            self.setupLabels()
        }
        
        if let dataSource = self.dataSource {
            timingForLyric = dataSource.timesForLyricPlayerView(self)
            length = dataSource.lengthOfLyricPlayerView?(self) ?? 0
        }
        
        nextLabelHaveToUpdate = .top
        self.showNextLabel()
    }
    
    func start() {
        if self.isLastLyric() {
            self.prepareToPlay()
        }
        
        if indexTiming == 0 {
            let timing = TimeInterval(timingForLyric[indexTiming])
            timer = Timer.scheduledTimer(timeInterval: timing, target: self, selector: #selector(handleAnimationAndShowLabel(_:)), userInfo: nil, repeats: false)
            isPlaying = true
        } else {
            self.resume()
        }
        
        self.delegate?.lyricPlayerViewDidStart?(self)
    }
    
    func resume() {
        if !isPlaying {
            lyricTop.resumeAnimation()
            lyricBottom.resumeAnimation()
            
            timer = Timer.scheduledTimer(timeInterval: timeIntervalRemain, target: self, selector: #selector(handleAnimationAndShowLabel(_:)), userInfo: nil, repeats: false)
            isPlaying = true
        }
    }
    
    func stop() {
        if isPlaying {
            timer?.invalidate()
            self.prepareToPlay()
            isPlaying = false
        }
    }
    
    func pause() {
        if isPlaying {
            if lyricTop.isAnimating {
                lyricTop.pauseAnimation()
            }
            
            if lyricBottom.isAnimating {
                lyricBottom.pauseAnimation()
            }
            
            if let timer = self.timer {
                timeIntervalRemain = timer.fireDate.timeIntervalSinceNow
                timer.invalidate()
                isPlaying = false
            }
        }
    }
    
    func setCurrentTime(_ currTime:CFTimeInterval) {
        timer?.invalidate()
        var isCurrentTimeBetween2Timing = false
        
        for i in 0...timingForLyric.count-1 {
            let t = CFTimeInterval(timingForLyric[i])
            
            if t == currTime {
                indexTiming = i
                timeIntervalRemain = 0
                break
            } else if t > currTime {
                indexTiming = i - 1
                timeIntervalRemain = t - currTime
                isCurrentTimeBetween2Timing = true
                break
            }
        }
        
        nextLabelHaveToUpdate = (indexTiming % 2 == 0) ? .top : .bottom
        
        if isCurrentTimeBetween2Timing {
            self.showNextLabel()
            indexTiming += 1
        }
        
        self.showNextLabel()
        if isPlaying {
            timer = Timer.scheduledTimer(timeInterval: timeIntervalRemain, target: self, selector: #selector(handleAnimationAndShowLabel(_:)), userInfo: nil, repeats: false)
        }
    }
}
