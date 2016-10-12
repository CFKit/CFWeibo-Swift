//
//  UIBarButtonItem+Extension.swift
//  CFWeibo
//
//  Created by 成飞 on 16/4/11.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit


extension UIBarButtonItem {
    /// 遍历构造函数
    ///
    /// - parameter imageName:  imageName
    /// - parameter target:     target
    /// - parameter actionName: actionname
    ///
    /// - returns: UIBarButtonItem
    convenience init(imageName: String, target: AnyObject?, actionName: String?) {
        let button = UIButton(imageName: imageName)
        // 添加监听
        if target != nil && actionName != nil {
            button.addTarget(target, action: Selector(actionName!), for: UIControlEvents.touchUpInside)
        }
        
        self.init(customView: button)
        
    }
    
    /// 遍历构造函数
    ///
    /// - parameter imageName:  imageName
    /// - parameter target:     target
    /// - parameter selector:   selector
    ///
    /// - returns: UIBarButtonItem
    convenience init(imageName: String, target: AnyObject?, selector: Selector?) {
        let button = UIButton(imageName: imageName)
        // 添加监听
        if target != nil && selector != nil {
            button.addTarget(target, action: selector!, for: UIControlEvents.touchUpInside)
        }
        
        self.init(customView: button)
        
    }

}
