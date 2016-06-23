//
//  UINavationBar+Extension.swift
//  CFWeibo
//
//  Created by 成飞 on 16/6/17.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit

extension UINavigationBar {
    class func findHairlineImageViewUnder(view: UIView?) -> UIImageView? {
        guard let v = view else {
            return nil
        }
        
        if v.isKindOfClass(UIImageView) && v.bounds.size.height <= 1.0 {
            return view as? UIImageView
        }
        
        for subView in v.subviews {
            print("\(subView) -- \(subView.backgroundColor)")
            subView.backgroundColor = UIColor.clearColor()
            subView.alpha = 0
            subView.opaque = false
            let imageView = self.findHairlineImageViewUnder(subView)
            if imageView != nil {
                return imageView
            }
        }
        
        return nil
    }
}
