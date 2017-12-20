//
//  UIImageExtension.swift
//  Demo_Chat
//
//  Created by Nguyen Van Hung on 2/27/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func scaleImage(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let result: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return result
    }
    
    func createRadius(size: CGSize, radius: CGFloat, byRoundingCorners: UIRectCorner?) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let imgRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        if let roundingCorners = byRoundingCorners {
            UIBezierPath(roundedRect: imgRect, byRoundingCorners: roundingCorners, cornerRadii: CGSize(width: radius, height: radius)).addClip()
        } else {
            UIBezierPath(roundedRect: imgRect, cornerRadius: radius).addClip()
        }
        self .draw(in: imgRect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result!
    }
}

extension UIImageView {
    func rotate() {
        if self.layer.animation(forKey: "cdImage") == nil {
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotateAnimation.toValue = M_PI * 2
            rotateAnimation.duration = 13
            rotateAnimation.repeatCount = HUGE
            rotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            self.layer.speed = 1
            self.layer.add(rotateAnimation, forKey: "cdImage")
        }
    }
    
    func pauseRotate() {
        let pauseTime = self.layer.convertTime(CACurrentMediaTime(), from: nil)
        self.layer.speed = 0.0
        self.layer.timeOffset = pauseTime
    }
    
    func resumeRotate() {
        let pauseTime = self.layer.timeOffset
        self.layer.speed = 1.0
        self.layer.timeOffset = 0.0
        self.layer.beginTime = 0.0
        self.layer.beginTime = layer.convertTime(CACurrentMediaTime(), from: nil) - pauseTime
    }
    
    func stopRotate() {
        self.layer.removeAllAnimations()
    }
}
