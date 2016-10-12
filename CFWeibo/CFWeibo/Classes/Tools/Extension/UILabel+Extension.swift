//
//  UILabel+Extension.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/18.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit

extension UILabel {
    /// 遍历构造函数
    ///
    /// - parameter title:    文字
    /// - parameter color:    颜色
    /// - parameter fontSize: 字体大小
    /// - parameter layoutWidth: 布局宽度，一旦大于 0 就是多行文本
    /// - parameter isBold: 是否加粗
    /// - returns: label
    public convenience init(title: String?, color: UIColor, fontSize: CGFloat, layoutWidth: CGFloat = 0, isBold: Bool = false) {
        //  实例化当前对象
        self.init()
        
        //  设置对象属性
        text = title
        textColor = color
        font = isBold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
        if layoutWidth > 0 {
            preferredMaxLayoutWidth = layoutWidth
            numberOfLines = 0
        }
        
        sizeToFit()
    }
    
    public func printText() {
        print(self.text)
    }
    
}

