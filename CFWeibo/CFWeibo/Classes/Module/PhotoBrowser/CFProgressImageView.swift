//
//  CFProgressImageView.swift
//  CFWeibo
//
//  Created by 成飞 on 16/6/21.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit

class CFProgressImageView: UIImageView {
    
    var progress: CGFloat = 0 {
        didSet {
            progressView.progress = progress
        }
    }
    
    private lazy var progressView: CFProgressView = {
        let pv = CFProgressView()
        //  添加控件
        self.addSubview(pv)
        //  设置大小
        pv.frame = self.bounds
        pv.backgroundColor = UIColor.clearColor()
        return pv
    }()
    
    /// 在 imageView 中，drawRect 函数不会被调用到
    

    /// 类中类 专供 CFProgressImageView 使用
    private class CFProgressView: UIView {
        //  进度数值 0-1
        var progress: CGFloat = 0 {
            didSet {
                setNeedsDisplay()
            }
        }
        
        //  rect - view.bounds
        //  drawRect 一旦被调用，所有的内容都会重新被绘制
        private override func drawRect(rect: CGRect) {
//            printLog("\(rect) - \(progress)")
            
            if progress >= 1 {
                return
            }
            
            //  绘图
            /**
             arcCenter: 中心点,
             radius: 半径,
             startAngle: 起始角度,
             endAngle: 结束角度,
             clockwise: 是否顺时针
             */
            let center  = CGPoint(x: rect.width * 0.5, y: rect.height * 0.5)
            let r = min(rect.width, rect.height) * 0.5
            let start = -CGFloat(M_PI_2)
            let end = 2 * CGFloat(M_PI) * progress + start
            let path = UIBezierPath(arcCenter: center, radius: r, startAngle: start, endAngle: end, clockwise: true)
            
            //  增加指向圆心的路径
            path.addLineToPoint(center)
            //  关闭路劲，产生一个扇形
            path.closePath()
            
            //  设置属性
//            path.lineWidth = 10;
            UIColor(white: 0.0, alpha: 0.5).setFill()
            path.stroke()
        }
    }
}
