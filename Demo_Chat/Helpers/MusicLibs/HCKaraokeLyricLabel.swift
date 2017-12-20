//
//  HCKaraokeLyricLabel.swift
//  Demo_Chat
//
//  Created by HungNV on 8/7/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

protocol HCKaraokeLyricViewDelegate: class {
    func karaokeLyric(_ label: HCKaraokeLyricLabel, didStartAnimation: CAAnimation)
    func karaokeLyric(_ label: HCKaraokeLyricLabel, didStopAnimation: CAAnimation, finished: Bool)
}

final class HCKaraokeLyricLabel: UILabel, CAAnimationDelegate {
    weak var delegate: HCKaraokeLyricViewDelegate?
    var duration: CGFloat = 0.25
    
    fileprivate var textLayer: CATextLayer = CATextLayer()
    fileprivate let animationKey = "runLyric"
    
    var isAnimating: Bool {
        return textLayer.speed > 0
    }
    
    var fillTextColor: UIColor? {
        didSet {
            guard let fillTextColor = self.fillTextColor else { return }
            textLayer.foregroundColor = fillTextColor.cgColor
        }
    }
    
    var lyricSegment: Dictionary<CGFloat,String>? {
        didSet {
            guard let lyricSegment = self.lyricSegment else { return }
            let sortedKeys = Array(lyricSegment.keys).sorted(by: <)
            
            var fullText = ""
            for k in sortedKeys {
                if let segmentStr = lyricSegment[k] {
                    fullText = fullText + segmentStr
                }
            }
            
            self.text = fullText
        }
    }
    
    override var text: String? {
        didSet {
            self.updateLayer()
        }
    }
    
    //MARK:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.prepareForLyricLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.prepareForLyricLabel()
    }
    
    func prepareForLyricLabel() {
        textLayer.removeFromSuperlayer()
        
        textLayer = CATextLayer()
        textLayer.frame = self.bounds
        
        self.numberOfLines = 1
        self.clipsToBounds = true
        self.textAlignment = .left
        self.baselineAdjustment = .alignBaselines
        
        textLayer.foregroundColor = fillTextColor?.cgColor ?? UIColor.blue.cgColor
        
        let textFont = self.font
        textLayer.font = textFont?.fontName as CFTypeRef?
        textLayer.fontSize = (textFont?.pointSize)!
        textLayer.string = self.text
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.masksToBounds = true
        
        textLayer.anchorPoint = CGPoint(x: 0, y: 0.5)
        textLayer.frame = self.bounds
        textLayer.isHidden = true
        self.layer.addSublayer(textLayer)
    }
    
    //MARK:- Help methods
    func updateLayer() {
        self.sizeToFit()
        self.setNeedsLayout()
        self.prepareForLyricLabel()
    }
    
    func valuesFromLyricSegment() -> Array<CGFloat> {
        let layerWidth = textLayer.bounds.size.width
        
        guard let lyricSegment = self.lyricSegment else { return [0.0, layerWidth] }
        
        var values:Array<CGFloat> = [0.0]
        let sortedKeys = Array(lyricSegment.keys).sorted( by: < )
        
        var val:CGFloat = 0
        for k in sortedKeys {
            let str = lyricSegment[k]!
            let strWidth = str.size(attributes: [NSFontAttributeName:self.font]).width
            val += strWidth
            values.append(val)
        }
        
        return values
    }
    
    func keyTimesFromLyricSegment() -> Array<CGFloat> {
        guard let lyricSegment = self.lyricSegment else { return [0.0, 1.0] }
        
        let keyTimes: Array<CGFloat> = [0.0] + Array(lyricSegment.keys).sorted(by: <) + [1.0]
        
        return keyTimes
    }
    
    func pauseLayer() {
        let pauseTime = textLayer.convertTime(CACurrentMediaTime(), from: nil)
        textLayer.speed = 0.0
        textLayer.timeOffset = pauseTime
    }
    
    func resumeLayer() {
        let pauseTime = textLayer.timeOffset
        textLayer.speed = 1.0
        textLayer.timeOffset = 0.0
        textLayer.beginTime = 0.0
        textLayer.beginTime = textLayer.convertTime(CACurrentMediaTime(), from: nil) - pauseTime
    }
    
    //MARK:- Animation
    func animationForTextLayer() -> CAKeyframeAnimation {
        textLayer.isHidden = false
        
        let textAnimation = CAKeyframeAnimation(keyPath: "bounds.size.width")
        textAnimation.duration = CFTimeInterval(self.duration)
        textAnimation.values = valuesFromLyricSegment()
        textAnimation.keyTimes = keyTimesFromLyricSegment() as [NSNumber]?
        textAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)]
        textAnimation.isRemovedOnCompletion = true
        textAnimation.delegate = self
        
        return textAnimation
    }
    
    //MARK:- Main methods
    func startAnimation() {
        guard let _ = textLayer.animation(forKey: animationKey) else {
            let anim = self.animationForTextLayer()
            textLayer.add(anim, forKey: animationKey)
            
            return
        }
    }
    
    func pauseAnimation() {
        guard let _ = textLayer.animation(forKey: animationKey) else { return }
        
        self.pauseLayer()
    }
    
    func resumeAnimation() {
        guard let _ = textLayer.animation(forKey: animationKey) else { return }
        
        self.resumeLayer()
    }
    
    func reset() {
        textLayer.removeAnimation(forKey: animationKey)
        textLayer.isHidden = true
    }
    
    //MARK:- Delegate
    func animationDidStart(_ anim: CAAnimation) {
        self.delegate?.karaokeLyric(self, didStartAnimation: anim)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.delegate?.karaokeLyric(self, didStopAnimation: anim, finished: flag)
    }
}
