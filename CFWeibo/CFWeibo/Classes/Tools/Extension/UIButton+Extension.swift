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
        
        setTitle(title, for: UIControlState())
        setImage(UIImage(named : imageName), for: UIControlState())
        setTitleColor(color, for: UIControlState())
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        
    }
    
    
    /// 遍历构造函数
    ///
    /// - parameter title:     标题
    /// - parameter fontSize:  字体
    /// - parameter color:     颜色
    /// - parameter backColor: 背景色
    ///
    /// - returns: button
    convenience init(title: String, fontSize: CGFloat) {
        self.init()
        
        setTitle(title, for: UIControlState())
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
    }

    /// 遍历构造函数
    ///
    /// - parameter title:     标题
    /// - parameter fontSize:  字体
    /// - parameter color:     颜色
    /// - parameter backColor: 背景色
    ///
    /// - returns: button
    convenience init(title: String, fontSize: CGFloat, color: UIColor = UIColor.white, backColor: UIColor = UIColor.darkGray) {
        self.init(title: title, fontSize: fontSize)
        
        setTitleColor(color, for: UIControlState())
        backgroundColor = backColor
    }

    
    convenience init(imageName: String) {
        self.init()
        
        setImage(UIImage(named: imageName), for: UIControlState())
        setImage(UIImage(named: imageName + "_highlighted"), for: UIControlState.highlighted)
        sizeToFit()
    }

}

