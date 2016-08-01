//
//  CFPhotoBrowserCell.swift
//  CFWeibo
//
//  Created by 成飞 on 16/6/16.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
import SDWebImage
import SVProgressHUD

let kPhotoBrowserCellIdentifier = "CFPhotoBrowserCell"

/// 照片浏览器cell 负责显示单张图片
class CFPhotoBrowserCell: UICollectionViewCell {
    var hasLoadedImage: Bool = false
    
    var newContentOffset: CGPoint = CGPointZero
    
    var placeholderImage: UIImage?
    
    var url: NSURL? {
        didSet {
            resetScrollView()
            //  打开指示器
            indicator.startAnimating()
            imageView.image = nil
            //  提问：对于 SDWebImage 如果设置了 image URL 图片会出现重用么
            //  原因：sdwebimage 一旦设置了 url 和之前的 url 不一致，会将 image 设置为 nil
            
            /// 模拟指示器
            /// dispatch_time_t  从什么时候开始，持续多久
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0 * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
                //  之前 imageView 没有指定大小
                //  RefreshCached 如果服务器的图像变化，而本地的图像是之前的图像，使用此选项，会更新服务器的图片。GET 方法能够缓存，如果服务器返回的状态码是 304，表示内容没有变化，否则使用服务器返回的图片  RefreshCached -> 会回调两次（原因不太清楚）
                //  RetryFailed 可以允许失败后重试
                self.imageView.sd_setImageWithURL(self.url, placeholderImage: self.placeholderImage, options: [SDWebImageOptions.RetryFailed]) { (image, error, _, _) in
                    print("+++++++++++++++++")
                    self.indicator.stopAnimating()
                    //  判断图像是否下载完成
                    if error != nil {
                        SVProgressHUD.showInfoWithStatus("您的网络不给力")
                        return;
                    }
                    //  执行到此处时表示图片已经加载完成
                    self.setScrollViewZoom()
                    self.setImagePosition()
                }

            }
            
        }
    }
    
    //  根据 ScrollView 的宽度， 计算缩放后的比例
    private func displaySize(image: UIImage) -> CGSize {
        
        // 1. 图像宽高比
        let scale = image.size.height / image.size.width
        // 2. 计算高度
        let w = scrollView.bounds.width
        let h = w * scale
        
        return CGSize(width: w, height: h)
    }
    
    //  根据图片大小设置 scrollView 的缩放比例
    private func setScrollViewZoom() {
        guard let image = imageView.image else { return; }

        let imageW = image.size.width
        let imageH = image.size.height
        /*
         image宽度大于高度时，
            最大缩放比例为 屏幕高度/iamge的高度，否则为 image长宽的三倍(最小为1)
         
         */
        
        scrollView.maximumZoomScale = imageW > imageH ? kScreenHeight * imageW / (imageH * kScreenWidth) : (imageW * 3 > kScreenWidth ? imageW * 3.0 / kScreenWidth : 1.0)
        scrollView.minimumZoomScale = imageW / kScreenWidth > 1.0 ? 1.0 : imageW / kScreenWidth
    }
    
    //  设置图像位置
    private func setImagePosition() {
        
        self.hasLoadedImage = true;
        //  如果图像缩放后没有屏幕高，居中
        let size = displaySize(imageView.image!)
        imageView.frame = CGRect(origin: CGPointZero, size: size)
        
        if size.height < scrollView.bounds.height {
            //  短图
            imageView.center = scrollView.center
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 重置 scrollView 的内容属性，因为缩放会影响到内容属性
    private func resetScrollView() {
        scrollView.contentSize = CGSizeZero
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.contentOffset = CGPointZero
        
        //  重新设置 imageView 的形变属性
        imageView.transform = CGAffineTransformIdentity
    }
    
    //  MARK: - 懒加载控件
    /// 缩放图片
    private lazy var scrollView = UIScrollView()
    /// 显示单张图片
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.userInteractionEnabled = true
        
        return iv
    } ()
    /// 菊花
    private lazy var indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
}

//  MARK: - 触发方法
extension CFPhotoBrowserCell {
    func singleTap(recognizer: UITapGestureRecognizer) {
        print("单击事件")
        
    }
    
    func doubleTap(recognizer: UITapGestureRecognizer) {
        if !self.hasLoadedImage { return }
        
        let touchPoint = recognizer.locationInView(self);
        if (self.scrollView.zoomScale <= 1.0) {
            let imageViewY = imageView.frame.origin.y
            let imageViewW = imageView.frame.size.width
            let imageViewH = imageView.frame.size.height
            
            //  需要放大的点
            let scale = imageViewW > imageViewH ? kScreenHeight / imageViewH : scrollView.maximumZoomScale
            
            //  判断 - 当放大后的高度不足频幕高度时
            if (imageViewH * scale < kScreenHeight) {  //  极端情况，图片不清楚时
                //  放大区域的宽和高
                let nowW = imageViewW / scale
                let nowH = imageViewH
                
                //  根据点击的点确定放大区域
                let originX: CGFloat
                if touchPoint.x < nowW * 0.5 {
                    originX = 0
                } else if touchPoint.x + nowW * 0.5 > kScreenWidth {
                    originX = kScreenWidth - nowW
                } else {
                    originX = touchPoint.x - 0.5 * nowW
                }
                let rect = CGRect(x: originX, y: imageViewY, width: nowW, height: nowH)
                scrollView.zoomToRect(rect, animated: true)
                scrollView.setContentOffset(CGPoint(x: rect.origin.x * scale, y: (rect.origin.y - imageViewY) * scale), animated: true)
            } else {
                //  缩放成功后 对应原图的大小
                let nowW = kScreenWidth / scale
                let nowH = kScreenHeight / scale
                
                //  根据点击的点确定放大区域
                let originX: CGFloat
                if touchPoint.x < nowW * 0.5 {
                    originX = 0
                } else if touchPoint.x + nowW * 0.5 > kScreenWidth {
                    originX = kScreenWidth - nowW
                } else {
                    originX = touchPoint.x - 0.5 * nowW
                }
                
                let originY: CGFloat
                if touchPoint.y - nowH * 0.5 < imageViewY {
                    originY = imageViewY
                } else if touchPoint.y + nowH * 0.5 > imageViewY + imageViewH {
                    originY = imageViewY + imageViewH - nowH
                } else {
                    originY = touchPoint.y - nowH * 0.5
                }
                
                let rect = CGRect(x: originX, y: originY, width: nowW, height: nowH)
                let offset = CGPoint(x: rect.origin.x * scale, y: (rect.origin.y - imageViewY) * scale)
                scrollView.zoomToRect(rect, animated: true)
                scrollView.setContentOffset(offset, animated: true)

            }
        } else {
            scrollView.setZoomScale(1.0, animated: true)
            scrollView.setContentOffset(CGPointZero, animated: true)
            print("还原")
        }
        
    }
    
    
}

//  MARK: - UIScrollViewDelegate
extension CFPhotoBrowserCell: UIScrollViewDelegate {
    //  告诉 scrollView 缩放哪一个视图
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    //  只要被缩放就会被调用
    /**
     *      形变小结
     *  1. a / d 决定 缩放比例
     *  2. tx / ty 决定 位移
     *  3. a b c d 共同决定旋转角度
     *  修改形变过程中，bounds 的数值不会发生变化，frame 的数值不会发生变化。
     *  bounds * transform => frmae
     */
    func scrollViewDidZoom(scrollView: UIScrollView) {
        
        self.imageView.center = self.centerOfScrollViewContent(scrollView)
    }
    
    /// 缩放完成后会被调用
    ///
    /// - parameter scrollView: scrollView
    /// - parameter view:       view - 被缩放的视图
    /// - parameter scale:      scale - 缩放完成的比例
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        print("移动完成后偏移量: \(scrollView.contentOffset)")
        print("image 大小: \(imageView.image!.size) \(scrollView.contentSize)")
    }

    /// 返回缩放过程中心点
    private func centerOfScrollViewContent(scrollView: UIScrollView) -> CGPoint {
        
        let offsetX = scrollView.bounds.size.width > scrollView.contentSize.width ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0
        let offsetY = scrollView.bounds.size.height > scrollView.contentSize.height ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0
        
        let actualCenter = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX,
                                   y: scrollView.contentSize.height * 0.5 + offsetY)
        return actualCenter
    }
    
}

extension CFPhotoBrowserCell {
    
    internal override func layoutSubviews() {
        super.layoutSubviews()
        self.adjustImageView()
    }
    
    private func adjustImageView() {
        
    }
    
    private func setupUI() {
        //  1. 添加控件
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        contentView.addSubview(indicator)
        
        //  2. 设置位置 让 scrollView 和 cell 一样大
        var rect = bounds
        rect.size.width -= 20
        scrollView.frame = rect;
        indicator.center = scrollView.center
        
        prepareScrollView()
    }
    
    //  准备 scrollView
    private func prepareScrollView() {
        //  设置代理
        scrollView.delegate = self
        
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CFPhotoBrowserCell.singleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.delaysTouchesBegan = true
        scrollView.addGestureRecognizer(singleTap)
        
        let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CFPhotoBrowserCell.doubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delaysTouchesBegan = true
        scrollView.addGestureRecognizer(doubleTap)
        //  只响应一个手势
        singleTap.requireGestureRecognizerToFail(doubleTap)
    }
    
}
