//
//  CFPhotoBrowserVC.swift
//  CFWeibo
//
//  Created by 成飞 on 16/6/14.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
import SVProgressHUD

let kPhotoMoreOperations = ["取消", "保存图片", "转发微博", "赞"]

class CFPhotoBrowserVC: UIViewController {
    /// 照片 URL 数组
    var urls: [NSURL]
    /// 占位图
    var placeholderImages: [UIImage]?
    /// 用户选中照片索引
    var selectedIndexPath: NSIndexPath
    
    /// 当前选中的图像索引
    var currentImageIndex: NSIndexPath {
        return collectionView.indexPathsForVisibleItems().last!
    }
    var currentImageView: UIImageView {
        let cell = collectionView.cellForItemAtIndexPath(currentImageIndex) as! CFPhotoBrowserCell
        
        return cell.imageView
    }
    
    /// 构造函数
    ///
    /// 简化外部调用，可以不适用可选属性，避免后续解包问题
    init(urls: [NSURL], placeholderImages: [UIImage]?, indexPath: NSIndexPath) {
        self.urls = urls
        self.placeholderImages = placeholderImages
        self.selectedIndexPath = indexPath
        super.init(nibName: nil, bundle: nil)  
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  MARK: - 系统方法
    override func loadView() {
        var rect = UIScreen.mainScreen().bounds
        rect.size.width += 20
        
        view = UIView(frame: rect)
        view.backgroundColor = UIColor.blackColor()
        
        setupUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("\(urls) - \(selectedIndexPath)")
    }
    
    //  视图出现
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //  collectionView 滚动到用户选择的图片
        collectionView.scrollToItemAtIndexPath(selectedIndexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "navigationbar_more_light"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CFPhotoBrowserVC.moreClicked))
        navigationItem.leftBarButtonItem = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let imageView = UINavigationBar.findHairlineImageViewUnder(self.navigationController?.navigationBar) {
            imageView.hidden = true
        }
        navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        navigationController?.navigationBar.translucent = true

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let imageView = UINavigationBar.findHairlineImageViewUnder(self.navigationController?.navigationBar) {
            imageView.hidden = false
        }
        UIApplication.sharedApplication().statusBarHidden = false
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        navigationController?.navigationBar.translucent = false
    }
    
    //  MARK: - 懒加载控件
    //  图片视图
    private lazy var collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    //  保存按钮
    private lazy var saveButton = UIButton(title: "保存", fontSize: 14)
    //  关闭按钮
    private lazy var closeButton = UIButton(title: "关闭", fontSize: 14)
    //  显示图片张数 label
    private lazy var numberLabel = UILabel(title: "", color: UIColor.whiteColor(), fontSize: 18, layoutWidth: 50, isBold: true)
    
}

//  MARK: - 触发事件
extension CFPhotoBrowserVC {
    //  保存图像
    @objc private func saveImage() {
        //  1. 获取图形
        //  提示：SDWebImage 不一定能够下载到图像
        guard let image = currentImageView.image else {
            SVProgressHUD.showInfoWithStatus("没有图像")
            return
        }
        
        //  2. 保存图像
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(CFPhotoBrowserVC.image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    //  - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
    @objc private func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {

        let message = (error == nil) ? "保存成功" : "保存失败"
        SVProgressHUD.showInfoWithStatus(message)
    }
    
    
    //  更多操作
    func moreClicked() {
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: kPhotoMoreOperations[0], destructiveButtonTitle: nil, otherButtonTitles: kPhotoMoreOperations[1], kPhotoMoreOperations[2], kPhotoMoreOperations[3])
        actionSheet.actionSheetStyle = UIActionSheetStyle.Default
        actionSheet.showInView(self.view)
    }
}

//  MARK: - 代理回调
extension CFPhotoBrowserVC: UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 1:
            //  保存图片
            self.saveImage()
            break
        case 2:
            //  转发微博
            break
        case 3:
            //  赞
            break
        default:
            break
            
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kPhotoBrowserCellIdentifier, forIndexPath: indexPath) as! CFPhotoBrowserCell
        cell.url = urls[indexPath.row]
        numberLabel.text = urls.count > 1 ? "\(indexPath.row + 1)/\(urls.count)" : ""
        
        return cell
    }
    
}

//  MARK: - 初始化页面
extension CFPhotoBrowserVC {
    private func setupUI() {
        //  添加控件
        view.addSubview(collectionView)
        view.addSubview(saveButton)
        view.addSubview(closeButton)
        view.addSubview(numberLabel)
        //  设置布局
        collectionView.frame = view.bounds
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let viewDict = ["sb": saveButton, "cb": closeButton, "nl": numberLabel];
        //  水平方向
        /*
            ==/>=/<=(自动布局的约束逻辑关系只有左面三种)
         */
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[sb(120)]-(>=8)-[cb(120)]-35-|", options: [], metrics: nil, views: viewDict))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[cb(35)]-15-|", options: [], metrics: nil, views: viewDict))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[sb(35)]-15-|", options: [], metrics: nil, views: viewDict))
        
        view.addConstraint(NSLayoutConstraint(item: numberLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: -10))
        view.addConstraint(NSLayoutConstraint(item: numberLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 30))
        prepareCollectionView()
        
        
        //  监听方法
        closeButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside).subscribeNext { [weak self] (btn) in
            self?.dismissViewControllerAnimated(true, completion: nil)
            
        }
        
        saveButton.addTarget(self, action: #selector(CFPhotoBrowserVC.saveImage), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    private func prepareCollectionView() {
        //  注册可重用cell
        collectionView.registerClass(CFPhotoBrowserCell.self, forCellWithReuseIdentifier: kPhotoBrowserCellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = view.bounds.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        collectionView.pagingEnabled = true
        
    }
    
}

