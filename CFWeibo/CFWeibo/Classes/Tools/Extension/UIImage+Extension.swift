//
//  UIImage+Extension.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/30.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit

extension UIImage {
    /// 将当前图片缩放到指定宽度
    ///
    /// - parameter width: 指定宽度
    ///
    /// - returns: UIImage(如果比指定宽度小，直接返回)
    func scaleImageToWidth(_ width: CGFloat) -> UIImage {
        //  1. 判断宽度
        if size.width < width { return self }
        
        //  2. 计算比例
        let height = width * (size.height / size.width)
        
        //  3. 绘图
        let newSize = CGSize(width: width, height: height)
        //  一旦开启上下文，所有绘图都在当前上下文中
        UIGraphicsBeginImageContext(newSize)
        //  在指定去云中缩放绘制完整图像
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        //  获取绘制结果
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func originImage(_ image: UIImage, scaleToSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
}

