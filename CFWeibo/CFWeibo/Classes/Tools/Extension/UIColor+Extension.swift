//
//  UIColor+Extension.swift
//  CFWeibo
//
//  Created by 成飞 on 16/6/16.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit

extension UIColor {
    /// 随机颜色
    ///
    /// - returns: UIColor
    class func randomColor() -> UIColor {
        //  Swift 3.0 新增随机颜色

        let r = CGFloat(arc4random() % 256) / 255
        let g = CGFloat(arc4random() % 256) / 255
        let b = CGFloat(arc4random() % 256) / 255
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }

}
