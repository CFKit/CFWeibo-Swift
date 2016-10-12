//
//  UIView+Extension.swift
//  CFWeibo
//
//  Created by 成飞 on 16/6/20.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit

extension UIView {
    /// 返回 view 在 window 中的相对位置
    ///
    /// - parameter superView: view 的父 view
    /// - parameter view: view
    ///
    /// - returns: rect
    class func convertRectInWindow(_ superView: UIView, view: UIView) -> CGRect {
        let rect = superView.convert(view.frame, to: UIApplication.shared.keyWindow!)
        return rect
    }
    
}
