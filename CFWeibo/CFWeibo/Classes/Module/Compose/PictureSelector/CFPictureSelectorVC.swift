//
//  CFPictureSelectorVC.swift
//  13. 照片选择
//
//  Created by 成飞 on 16/4/12.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit

protocol CFPictureSelectorVCDelegate: NSObjectProtocol {
    func pictureNumChange(count: Int)
}

private let kMaxPictureCount = 9

class CFPictureSelectorVC: UICollectionViewController, CFPictureCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //  MARK: -- 属性
        /// 照片数组
    lazy var pictures = [UIImage]()
        /// 用户选中照片索引
    private var currentIndex = 0
    
    weak var delegate: CFPictureSelectorVCDelegate?
    
    //  MARK: -- 继承方法
    init() {
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        let itemWidth = (kScreenWidth - 26) / 3.0
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.whiteColor()
        //  注册可重用cell
        self.collectionView?.registerClass(CFPictureCell.self, forCellWithReuseIdentifier: PictureCellIdentifier)
    }
}

// MARK: - 触发方法
extension CFPictureSelectorVC {
    func turnToImagePickerVCWithIndexPath(indexPath: NSIndexPath) {
        /*
         Camera             相机
         PhotoLibrary       照片库 - 包含相册，包括通过 iTunes/iPhone 同步的照片，同步的照片不允许在手机删除
         SavedPhotosAlbum   相册 - 相机拍摄，应用程序保存的图片，可以删除
         
         */
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
      
            print("无法访问相册")
            return
        }
        
        //  记录当前用户选中的照片
        currentIndex = indexPath.row
        
        //  访问相册
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        //        imagePickerVC.allowsEditing = true
        self.presentViewController(imagePickerVC, animated: true, completion: nil)
    }
    
    //  图片数量改变了
    func pictureNumChanged() {
        let imageNums = pictures.count == 9 ? 9 : pictures.count + 1
        self.delegate?.pictureNumChange(imageNums)
    }
}

// MARK: - 代理
extension CFPictureSelectorVC {
    //  MARK: -- CFPictureCellDelegate
    private func pictureCellClickedRemoveButton(cell: CFPictureCell) {
        
        if let indexPath = collectionView?.indexPathForCell(cell) {
            pictures.removeAtIndex(indexPath.row)
            pictureNumChanged()
            collectionView?.reloadData()
        }
        
    }
    
    //  MARK: -- UICollectionViewDelegate, UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return pictures.count + (pictures.count == kMaxPictureCount ? 0 : 1)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PictureCellIdentifier, forIndexPath: indexPath) as! CFPictureCell
        cell.pictureDelegate = self
        
        //  设置图片，比数据源多一个，让最后一个作为添加照片的按钮
        cell.image = indexPath.row < pictures.count ? pictures[indexPath.row] : nil
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        turnToImagePickerVCWithIndexPath(indexPath)
    }
    
    //  MARK: -- UIImagePickerControllerDelegate，UINavigationControllerDelegate
    /// 选中照片代理方法
    ///
    /// - parameter picker:      picker 选择控制器
    /// - parameter image:       选中的图像
    /// - parameter editingInfo: 编辑字典(在开发选择用户头像时可以用到，一旦选择编辑会变小)
    /// 一旦实现了代理方法，就需要自己关闭控制器，关于应用程序，UI的APP空的程序运行占用 20M ，一个 cocos2dx 空模板简历应用程序会占用 70M ， 一般程序在 100M 以内可以接受。
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        let scaleImage = image.scaleImageToWidth(300)
        
        //  严重影响图片质量
//        UIImageJPEGRepresentation(image, 0.1)
        
        /// 更新数据源，并刷新数据源
        if currentIndex < pictures.count {  //  用户选中了一张照片
            pictures[currentIndex] = scaleImage
        } else {    //  用户添加了新的照片
            pictures.append(scaleImage)
        }
        pictureNumChanged()
        collectionView?.reloadData()
        self.view.hidden = self.pictures.count == 0
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.view.hidden = self.pictures.count == 0
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}



// MARK: - 代理方法
private protocol CFPictureCellDelegate: NSObjectProtocol {
    /// 删除选中按钮 - collectionView/tableView Cell 一个视图会包含多个 cell，在定义代理方法的时候一定要传 cell，通过 cell 的属性，控制器能够判断出点击的对象
    func pictureCellClickedRemoveButton(cell: CFPictureCell)
    
}

// MARK: - 照片选择cell
//  可重用标识符
private let PictureCellIdentifier = "CFPictureCell"

private class CFPictureCell: UICollectionViewCell {

    
    var image: UIImage? {
        didSet {
            pictureButton.imageView?.contentMode =  UIViewContentMode.ScaleAspectFill
            pictureButton.setImage(image, forState: UIControlState.Normal)
            //  如果没有图像隐藏删除按钮
            removeButton.hidden = image == nil

        }
    }
    
        /// 定义代理
    weak var pictureDelegate: CFPictureCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 懒加载控件
    /// 添加照片按钮
    private lazy var pictureButton: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(UIImage(named: "compose_pic_add"), forState: UIControlState.Normal)
        return btn
    }()
    
    /// 删除照片按钮
    private lazy var removeButton = UIButton(imageName: "compose_photo_close")
    
}

// MARK: - 触发方法
extension CFPictureCell {
    @objc private func clickedRemoveButton() {
        pictureDelegate?.pictureCellClickedRemoveButton(self)
    }
}

// MARK: - 布局
extension CFPictureCell {
    private func setupUI() {
        contentView.addSubview(pictureButton)
        contentView.addSubview(removeButton)
        
        let viewDict = ["btn": removeButton]
        pictureButton.frame = bounds
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[btn]-0-|", options: [], metrics: nil, views: viewDict))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[btn]", options: [], metrics: nil, views: viewDict))
        
        //  禁用照片选择按钮 - 触发 collectionView 的 didselected 方法
        //  禁用按钮有一个损失: 不会再显示高亮图像
        pictureButton.userInteractionEnabled = false
        
        //  添加监听方法
        removeButton.addTarget(self, action: #selector(CFPictureCell.clickedRemoveButton), forControlEvents: UIControlEvents.TouchUpInside)
    }
}
