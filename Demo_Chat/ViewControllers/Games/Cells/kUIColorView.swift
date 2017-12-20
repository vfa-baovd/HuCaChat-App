//
//  kUIColorView.swift
//  Demo_Chat
//
//  Created by HungNV on 8/16/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

@IBDesignable class kUIColorView: UIView {
    var couponText = "Coupon"
    
    @IBInspectable var font:UIFont = UIFont.systemFont(ofSize: 8) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var triangleColor:UIColor = UIColor.white {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var isCoupon:Bool = false {
        didSet {
            if isCoupon {
                self.triangleColor = UIColor.orange
            }
            else {
                self.setNeedsDisplay()
            }
        }
    }
    
    @IBInspectable var image:UIImage! = nil {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        self.font = UIFont.systemFont(ofSize: 8.0 * rect.size.width / 35.0)
        triangleColor.setFill()
        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: 0, y: 0))
        trianglePath.addLine(to: CGPoint(x: rect.size.width, y: 0))
        trianglePath.addLine(to: CGPoint(x: 0, y: rect.size.height))
        trianglePath.close()
        
        trianglePath.fill()
        if isCoupon {
            let context = UIGraphicsGetCurrentContext()!
            context.saveGState()
            
            let textFontAttributes = [
                NSFontAttributeName: font,
                NSForegroundColorAttributeName: UIColor.white,
                ] as [String : Any]
            let size = couponText.size(attributes: textFontAttributes)
            context.translateBy(x: rect.size.width / 2, y: rect.size.height / 2)
            context.rotate(by: -CGFloat(M_PI_4))
            couponText.draw(at: CGPoint(x: -size.width / 2, y: -size.height), withAttributes: textFontAttributes)
            context.restoreGState()
        } else {
            if image != nil {
                let context = UIGraphicsGetCurrentContext()!
                UIColor.white.setFill()
                let f = CGRect(x: 5, y: 5, width: rect.size.width - 10, height: rect.size.height - 10)
                context.fillEllipse(in: f)
                
                let fImage = CGRect(x: 6, y: 6, width: rect.size.width - 12, height: rect.size.height - 12)
                image.draw(in: fImage)
            }
        }
    }
}
