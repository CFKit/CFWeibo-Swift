//
//  CFNewFeatureVC.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/8.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
//  可重用标识符
private let FeatureIdentifier = "CFFeatureCell"

private let NewFeatureCount = 4


class CFNewFeatureVC: UICollectionViewController {

    //  实现 init 构造函数，方便外部的代码调用，不需要额外指定布局属性
    init() {
        //  调用父类的默认构造函数
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationController?.viewControllers
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes（注册 Cell）
        self.collectionView!.register(CFNewFeatureCell.self, forCellWithReuseIdentifier: FeatureIdentifier)

        prepareLayout()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// 1. 准备布局
    fileprivate func prepareLayout() {
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.itemSize = UIScreen.main.bounds.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        
        collectionView?.isPagingEnabled = true
        collectionView?.bounces = false
        collectionView?.showsVerticalScrollIndicator = false

    }
    
    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return NewFeatureCount
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeatureIdentifier, for: indexPath) as! CFNewFeatureCell
        cell.imageIndex = (indexPath as NSIndexPath).item
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        let path = collectionView.indexPathsForVisibleItems.last!

        if (path as NSIndexPath).item == NewFeatureCount - 1 {
            let cell = collectionView.cellForItem(at: path) as! CFNewFeatureCell
            cell.showStartButton()
        }

    }
    
}

/// 新特性的cell，private 保证 cell 只能在当前控制器使用。在当前文件中，所有的private 都是摆设
private class CFNewFeatureCell: UICollectionViewCell {
    var imageIndex: Int = 0 {
        didSet {
            //  TODO: - 设置 cell
            iconView.image = UIImage(named: "new_feature_\(imageIndex + 1)")
            
            startButton.isHidden = true
        }
    }
    
    fileprivate func showStartButton() {
        startButton.isHidden = false
        startButton.transform = CGAffineTransform(scaleX: 0, y: 0)
        /// damping     弹性系数 0~1 越小越弹
        /// velocity    初始速度
        UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: [], animations: { () -> Void in
            self.startButton.transform = CGAffineTransform.identity
            }) { (_) -> Void in
                
        }
    }
    
    
    /// frame 的大小来自于 layout 的 itemSize
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    /// 设置界面元素
    fileprivate func setupUI() {
        addSubview(iconView)
        addSubview(startButton)
        
        iconView.frame = bounds
     
        startButton.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: startButton, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 1))
        addConstraint(NSLayoutConstraint(item: startButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: -100))
    }
    
    /// 图像视图
    fileprivate lazy var iconView = UIImageView()
    fileprivate lazy var startButton: UIButton = {
        let button = UIButton()
        button.setTitle("开始体验", for: UIControlState())
        button.setBackgroundImage(UIImage(named: "new_feature_finish_button"), for: UIControlState())
        button.setBackgroundImage(UIImage(named: "new_feature_finish_button_highlighted"), for: UIControlState.selected)
        button.sizeToFit()
        
        button.addTarget(self, action: #selector(CFNewFeatureCell.clickStartButton), for: UIControlEvents.touchUpInside)
        return button
    }()

    //  如果累屎私有的 如果没有对方法进行修饰，运行循环同样无法调用监听方法
    @objc func clickStartButton() {
        NotificationCenter.default.post(name: CFSwitchRootVCNotification, object: "CFMainVC")
    }
    
}
