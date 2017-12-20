//
//  CommonExtention.swift
//  Demo_Chat
//
//  Created by HungNV on 8/14/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import Foundation

extension Double {
    func convertToStringWithOneDecimal() -> String {
        return String(format: "%.1f", self)
    }
}

extension UINavigationController {
    func previousViewController() -> UIViewController? {
        let lenght = self.viewControllers.count
        let previousViewController: UIViewController? = lenght >= 2 ? self.viewControllers[lenght-2] : nil
        
        return previousViewController
    }
}

extension UISearchBar {
    func changeSearchBarColor(color: UIColor) {
        for subView in self.subviews {
            for subSubView in subView.subviews {
                if let _ = subSubView as? UITextInputTraits {
                    let textField = subSubView as! UITextField
                    textField.backgroundColor = color
                    break
                }
            }
        }
    }
    
    public func setStyleColor(_ color: UIColor) {
        tintColor = color
        guard let tf = (value(forKey: "searchField") as? UITextField) else { return }
        tf.textColor = color
        tf.backgroundColor = color
        if let glassIconView = tf.leftView as? UIImageView, let img = glassIconView.image {
            let newImg = img.blendedByColor(color)
            glassIconView.image = newImg
        }
        if let clearButton = tf.value(forKey: "clearButton") as? UIButton {
            clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            clearButton.tintColor = color
        }
    }
}

extension UIImage {
    public func blendedByColor(_ color: UIColor) -> UIImage {
        let scale = UIScreen.main.scale
        if scale > 1 {
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
        } else {
            UIGraphicsBeginImageContext(size)
        }
        color.setFill()
        let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIRectFill(bounds)
        draw(in: bounds, blendMode: .destinationIn, alpha: 1)
        let blendedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return blendedImage!
    }
}
