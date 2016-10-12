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
    var urls: [URL]
    /// 占位图
    var placeholderImages: [UIImage]?
    /// 用户选中照片索引
    var selectedIndexPath: IndexPath
    
    /// 当前选中的图像索引
    var currentImageIndex: IndexPath {
        return collectionView.indexPathsForVisibleItems.last!
    }
    var currentImageView: UIImageView {
        let cell = collectionView.cellForItem(at: currentImageIndex) as! CFPhotoBrowserCell
        
        return cell.imageView
    }
    
    /// 构造函数
    ///
    /// 简化外部调用，可以不适用可选属性，避免后续解包问题
    init(urls: [URL], placeholderImages: [UIImage]?, indexPath: IndexPath) {
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
        var rect = UIScreen.main.bounds
        rect.size.width += 20
        
        view = UIView(frame: rect)
        view.backgroundColor = UIColor.black
        
        setupUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("\(urls) - \(selectedIndexPath)")
    }
    
    //  视图出现
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //  collectionView 滚动到用户选择的图片
        collectionView.scrollToItem(at: selectedIndexPath, at: UICollectionViewScrollPosition.left, animated: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "navigationbar_more_light"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(CFPhotoBrowserVC.moreClicked))
        navigationItem.leftBarButtonItem = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let imageView = UINavigationBar.findHairlineImageViewUnder(self.navigationController?.navigationBar) {
            imageView.isHidden = true
        }
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.navigationBar.isTranslucent = true

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let imageView = UINavigationBar.findHairlineImageViewUnder(self.navigationController?.navigationBar) {
            imageView.isHidden = false
        }
        UIApplication.shared.isStatusBarHidden = false
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
    }
    
    //  MARK: - 懒加载控件
    //  图片视图
    fileprivate lazy var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    //  保存按钮
    fileprivate lazy var saveButton = UIButton(title: "保存", fontSize: 14)
    //  关闭按钮
    fileprivate lazy var closeButton = UIButton(title: "关闭", fontSize: 14)
    //  显示图片张数 label
    fileprivate lazy var numberLabel = UILabel(title: "", color: UIColor.white, fontSize: 18, layoutWidth: 50, isBold: true)
    
}

//  MARK: - 触发事件
extension CFPhotoBrowserVC {
    //  保存图像
    @objc fileprivate func saveImage() {
        //  1. 获取图形
        //  提示：SDWebImage 不一定能够下载到图像
        guard let image = currentImageView.image else {
            SVProgressHUD.showInfo(withStatus: "没有图像")
            return
        }
        
        //  2. 保存图像
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(CFPhotoBrowserVC.image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    //  - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
    @objc fileprivate func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {

        let message = (error == nil) ? "保存成功" : "保存失败"
        SVProgressHUD.showInfo(withStatus: message)
    }
    
    
    //  更多操作
    func moreClicked() {
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: kPhotoMoreOperations[0], destructiveButtonTitle: nil, otherButtonTitles: kPhotoMoreOperations[1], kPhotoMoreOperations[2], kPhotoMoreOperations[3])
        actionSheet.actionSheetStyle = UIActionSheetStyle.default
        actionSheet.show(in: self.view)
    }
}

//  MARK: - 代理回调
extension CFPhotoBrowserVC: UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPhotoBrowserCellIdentifier, for: indexPath) as! CFPhotoBrowserCell
        cell.url = urls[(indexPath as NSIndexPath).row]
        numberLabel.text = urls.count > 1 ? "\((indexPath as NSIndexPath).row + 1)/\(urls.count)" : ""
        
        return cell
    }
    
}

//  MARK: - 初始化页面
extension CFPhotoBrowserVC {
    fileprivate func setupUI() {
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
        
        let viewDict = ["sb": saveButton, "cb": closeButton, "nl": numberLabel] as [String : Any];
        //  水平方向
        /*
            ==/>=/<=(自动布局的约束逻辑关系只有左面三种)
         */
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[sb(120)]-(>=8)-[cb(120)]-35-|", options: [], metrics: nil, views: viewDict))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[cb(35)]-15-|", options: [], metrics: nil, views: viewDict))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[sb(35)]-15-|", options: [], metrics: nil, views: viewDict))
        
        view.addConstraint(NSLayoutConstraint(item: numberLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: -10))
        view.addConstraint(NSLayoutConstraint(item: numberLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 30))
        prepareCollectionView()
        
        
        //  监听方法
        closeButton.rac_signal(for: UIControlEvents.touchUpInside).subscribeNext { [weak self](btn) in
            self?.dismiss(animated: true, completion: nil)
        }
        
        saveButton.addTarget(self, action: #selector(CFPhotoBrowserVC.saveImage), for: UIControlEvents.touchUpInside)
    }
    
    fileprivate func prepareCollectionView() {
        //  注册可重用cell
        collectionView.register(CFPhotoBrowserCell.self, forCellWithReuseIdentifier: kPhotoBrowserCellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = view.bounds.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        
        collectionView.isPagingEnabled = true
        
    }
    
}

