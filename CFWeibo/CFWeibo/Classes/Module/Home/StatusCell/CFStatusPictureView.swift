//
//  CFStatusPictureView.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/22.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
import SDWebImage


//  MARK: - 通知常量，保存在常量区。足够长可以避免重复
let kStatusPictureViewSelectedPhotoNotification = "kStatusPictureViewSelectedNotification"
//  选中索引
let kStatusPictureViewSelectedPhotoIndexPathKey = "kStatusPictureViewSelectedPhotoIndexPathKey"
//  选中图片 URLs
let kStatusPictureViewSelectedPhotoURLsKey = "kStatusPictureViewSelectedPhotoURLsKey"

class CFStatusPictureView: UICollectionView {
    /// 微博数据视图模型
    var statusVM: CFStatusVM? {
        didSet {
            sizeToFit()
            //  每次设置都要刷新数据
            reloadData()
        }
    }
    
    var imageContentMode: UIViewContentMode = UIViewContentMode.ScaleAspectFill
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        return calcViewSize()
    }
    /// 根据模型中图片数量返回视图大小
    private func calcViewSize() -> CGSize {
        let layout = collectionViewLayout as! CFStatusPictureViewFlowLayout
        layout.itemSize = CGSize(width: kStatusPictureItemWidth, height: kStatusPictureItemWidth)
        let count = statusVM?.bmiddleURLs?.count ?? 0
        
        imageContentMode = UIViewContentMode.ScaleAspectFill
        
        if count == 0 {
            return CGSizeZero
        } else if count == 1 {
            
            var size = CGSize(width: kStatusPictureItemWidth, height: kStatusPictureItemWidth)
            //  判断图片是否已经被正确缓存 key 是 URL 的完成字符串
            let key = statusVM?.bmiddleURLs![0].absoluteString
            if let image = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(key) {
                size = image.size
            }
            
            //  处理过宽或者过窄的图片
            let maxwidth = kScreenWidth - 2 * kStatusCellMargin
            if size.width > maxwidth || size.height > kScreenHeight / 2 {
                size.width = maxwidth / 2
                size.height = kScreenHeight / 3
                imageContentMode = UIViewContentMode.Top
            }
            
            layout.itemSize = size
            return size
        } else if count == 4 {
            let w = kStatusPictureItemWidth * 2 + kStatusPictureItemMargin
            return CGSize(width: w, height: w)
        } else {
            let row = CGFloat((count + Int(kStatusPictureMaxCount - 1)) / Int(kStatusPictureMaxCount))
            return CGSize(width: kStatusPictureMaxWidth, height: row * (kStatusPictureItemWidth + kStatusPictureItemMargin) - kStatusPictureItemMargin)
        }
        
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        //  默认 layout 没有被初始化
        super.init(frame: frame, collectionViewLayout: CFStatusPictureViewFlowLayout())
        backgroundColor = UIColor.whiteColor()
        
        //  指定数据源(自己当自己的数据源) 代理
        /*
            1. 在自定义 view 中，代码逻辑相对简单，可以考虑自己充当自己的数据源
            2. dataSource & delegate 本身都是弱引用，自己充当自己的代理不会产生循环引用
            3. 除了配图视图、自定义 pickerView（省市联动的）
        */
        dataSource = self
        delegate = self;
        
        //  注册 cell 
        registerClass(CFStatusPictureCell.self, forCellWithReuseIdentifier: kStatusPictureCellIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//  MARK: - UICollectionViewDataSource
extension CFStatusPictureView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return statusVM?.bmiddleURLs?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kStatusPictureCellIdentifier, forIndexPath: indexPath) as! CFStatusPictureCell
        
        cell.imageURL = statusVM!.bmiddleURLs![indexPath.row]
        cell.imageContentMode = imageContentMode

        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        /**
            发送通知
         object: 发送的对象，可以传递一个数值，也可以是自己
         userInfo: 可选字典，可以传递多个数值
         */
        NSNotificationCenter.defaultCenter().postNotificationName(kStatusPictureViewSelectedPhotoNotification, object: self, userInfo: [kStatusPictureViewSelectedPhotoIndexPathKey: indexPath, kStatusPictureViewSelectedPhotoURLsKey: statusVM!.originalURLs!])
        
//        let rect = screenRect(indexPath)
//        let fullRect = fullScreenRect(indexPath)
//        
//        print("\(rect), \(fullRect)")
    
    }
    
    func screenRect(indexPath: NSIndexPath) -> CGRect {
        let rect = UIView.convertRectInWindow(self, view: self.cellForItemAtIndexPath(indexPath)!)
        return rect
    }
    
    func fullScreenRect(indexPath: NSIndexPath) -> CGRect {
        //  根据 [缩略图] 图片计算目标尺寸
        let key = statusVM?.bmiddleURLs![indexPath.item].absoluteString
        guard let image = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(key) else {
            return CGRectZero
        }
        
        let scale = image.size.height / image.size.width
        let w = UIScreen.mainScreen().bounds.width
        let h = scale * w
        
        //  判断高度
        var y = (UIScreen.mainScreen().bounds.height - h) * 0.5
        if y < 0 {
            y = 0
        }
        
        return CGRect(x: 0, y: y, width: w, height: h)
    }
    
}


private let kStatusPictureCellIdentifier = "CFStatusPictureItem"
//  MARK: - CFStatusPictureItem
private class CFStatusPictureCell: UICollectionViewCell {
    //  配图视图的 URL
    var imageURL: NSURL? {
        didSet {
            iconView.sd_setImageWithURL(imageURL)
            
            let pathExtension = (imageURL!.absoluteString as NSString).pathExtension
            gifIconView.hidden = pathExtension.lowercaseString != "gif"
        }
    }
    
    var imageContentMode: UIViewContentMode? {
        didSet {
            iconView.contentMode = imageContentMode!
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()
        addSubview(iconView)
        iconView.addSubview(gifIconView)
        iconView.ff_Fill(self)
        gifIconView.ff_AlignInner(type: ff_AlignType.BottomRight, referView: iconView, size: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //  MARK: - 懒加载
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        return imageView
    } ()
    /// gif 指示图片
    private lazy var gifIconView = UIImageView(image: UIImage(named: "timeline_image_gif"))
    
    
}

//  MARK: - CFStatusPictureItemFlowLayout
private class CFStatusPictureViewFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        minimumLineSpacing = kStatusPictureItemMargin
        minimumInteritemSpacing = kStatusPictureItemMargin
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
