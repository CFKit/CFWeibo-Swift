//
//  UIButton+Extension.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/22.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit

extension UIButton {
    /// 遍历构造函数
    ///
    /// - parameter title:     标题
    /// - parameter imageName: 图片名
    /// - parameter color:     颜色
    /// - parameter fontSize:  字体
    ///
    /// - returns: button
    convenience init(title: String, imageName: String, color: UIColor, fontSize: CGFloat) {
        self.init()
        
        setTitle(title, forState: UIControlState.Normal)
        setImage(UIImage(named : imageName), forState: UIControlState.Normal)
        setTitleColor(color, forState: UIControlState.Normal)
        titleLabel?.font = UIFont.systemFontOfSize(fontSize)
        
    }
    
    /// 遍历构造函数
    ///
    /// - parameter title:     标题
    /// - parameter fontSize:  字体
    /// - parameter color:     颜色
    /// - parameter backColor: 背景色
    ///
    /// - returns: button
    convenience init(title: String, fontSize: CGFloat, color: UIColor = UIColor.whiteColor(), backColor: UIColor = UIColor.darkGrayColor()) {
        self.init()
        
        setTitle(title, forState: UIControlState.Normal)
        setTitleColor(color, forState: UIControlState.Normal)
        titleLabel?.font = UIFont.systemFontOfSize(fontSize)
        backgroundColor = backColor
    }

    
    convenience init(imageName: String) {
        self.init()
        
        setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        setImage(UIImage(named: imageName + "_highlighted"), forState: UIControlState.Highlighted)
        sizeToFit()
    }

}

