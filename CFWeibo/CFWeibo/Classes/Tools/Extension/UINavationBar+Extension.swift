//
//  UINavationBar+Extension.swift
//  CFWeibo
//
//  Created by 成飞 on 16/6/17.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit

extension UINavigationBar {
    class func findHairlineImageViewUnder(_ view: UIView?) -> UIImageView? {
        guard let v = view else {
            return nil
        }
        
        if v.isKind(of: UIImageView.self) && v.bounds.size.height <= 1.0 {
            return view as? UIImageView
        }
        
        for subView in v.subviews {
            print("\(subView) -- \(subView.backgroundColor)")
            subView.backgroundColor = UIColor.clear
            subView.alpha = 0
            subView.isOpaque = false
            let imageView = self.findHairlineImageViewUnder(subView)
            if imageView != nil {
                return imageView
            }
        }
        
        return nil
    }
}
