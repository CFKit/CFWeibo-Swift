//
//  CFPhotoBrowserAnimator.swift
//  CFWeibo
//
//  Created by 成飞 on 16/6/20.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
import SDWebImage

/// 专门供从控制器向照片浏览器 Modal '转场' 动画的对象
class CFPhotoBrowserAnimator: NSObject, UIViewControllerTransitioningDelegate {
    //  是否展现标记
    var isPresented = false
    //  起始位置
    var fromRect = CGRectZero
    //  目标位置
    var toRect = CGRectZero
    
    var placeholderImage: UIImage?
    
    var url: NSURL?
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = UIViewContentMode.ScaleAspectFill
        iv.clipsToBounds = true
        return iv
    } ()
    
    /// 首页视图控制器中的配图视图 - 本事上是 homevc 的 cell 对其进行强引用
    weak var picView: CFStatusPictureView?
    
    func prepareAnimator(fromRect: CGRect, toRect: CGRect, url: NSURL, placeholderImage: UIImage?, picView: CFStatusPictureView) {
        self.fromRect = fromRect
        self.toRect = toRect
        self.url = url
        self.picView = picView
        self.placeholderImage = placeholderImage
    }
    
    /// 返回提供转场动画的对象
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresented = true
        return self
    }
    
    /// 返回解除转场动画的对象
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresented = false
        return self
    }

}

extension CFPhotoBrowserAnimator: UIViewControllerAnimatedTransitioning {
    /// 返回转场动画时长
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    /// 实现转场动画效果 - 一旦实现了此方法，程序员必须完成此效果
    ///
    /// - parameter transitionContext: 提供了转场动画所需的一切细节
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
//        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
//        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
//        
//        printLog("\n\(fromVC)\n\(toVC)")
        isPresented ? presentedAnimation(transitionContext) : dismissedAnimation(transitionContext)
    }
    
    
    private func presentedAnimation(transitionContext: UIViewControllerContextTransitioning) {
        
        //  1. 将 imageView 添加到容器视图
        let backView = UIView(frame: UIScreen.mainScreen().bounds)
        backView.backgroundColor = UIColor.clearColor()
        backView.addSubview(imageView)
        imageView.frame = fromRect
        
        transitionContext.containerView()?.addSubview(backView)
        //  2. 用 SDWebImage 异步下载图像
        /**
         1> 如果图片已经被缓存，不会再次下载
         2> 如果要跟进进度，都是'异步'回调
            原因：一般程序不会跟踪进度，进度回调的频率相对较高。
                 异步回调，能够价格低对主线程的压力
         */
        imageView.sd_setImageWithURL(url, placeholderImage: placeholderImage, options: [SDWebImageOptions.RetryFailed], progress: nil) { (_, error, _, _) in
            //  判断是否有错误
            if error != nil {
                printLog(error, logError: true)
                transitionContext.completeTransition(false)
                return
            }
            
            //  3. 图像下载完成之后，再显示动画
            UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
                backView.backgroundColor = UIColor.blackColor()
                self.imageView.frame = self.toRect
                }, completion: { (_) in
                    //  4. 将目标视图添加到容器视图
                    let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
                    transitionContext.containerView()?.addSubview(toView)
                    //  将 imageView 从界面上移除
                    backView.removeFromSuperview()
                    //  声明动画完成
                    transitionContext.completeTransition(true)
                    
            })

        }

    }
    
    private func dismissedAnimation(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! CFPhotoBrowserVC
        let imageView = fromVC.currentImageView
        let indexPath = fromVC.currentImageIndex
        
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        //  将 fromView 从容器视图中移除
        fromView.removeFromSuperview()
        //  将图像视图添加到容器视图
        transitionContext.containerView()?.addSubview(imageView)
        imageView.frame = toRect
        
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
            //  通过控制器获得内部的 imageView
            imageView.contentMode = self.picView!.imageContentMode
            imageView.clipsToBounds = true
            imageView.frame = self.picView!.screenRect(indexPath)
            }) { (_) in
                imageView.removeFromSuperview()
                transitionContext.completeTransition(true)
        }
    }
}
