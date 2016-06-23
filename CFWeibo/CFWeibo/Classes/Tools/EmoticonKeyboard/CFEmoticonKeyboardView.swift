//
//  CFEmoticonKeyboardView.swift
//  test
//
//  Created by 成飞 on 16/6/7.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit

let kMaxRow = 3
let kMaxLine = 7


/*
 1. 撰写微博的控制器一旦释放，表情模型同样会被释放，再次使用，再次加载，效率不好
 2. 点击表情键盘中的表情图片，不走textDidChanged
 3. 最近的表情没有记录，影响用户体验
 */
class CFEmoticonKeyboardView: UIView {
    var selectedEmoticonCallBack: (emoticon: CFEmoticonM)->()
    
    init(selectedEmoticon: (emoticon: CFEmoticonM) -> ()) {
        selectedEmoticonCallBack = selectedEmoticon
        super.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 216))
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 懒加载控件
    /// 工具栏
    private lazy var toolbar = UIToolbar()
    /// collectionView
    private lazy var collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: CFEmoticonFlowLayout())
    /// 表情包的视图模型
    private lazy var emoticonVM = CFEmoticonVM.sharedEmoticonVM

}

// MARK: - 页面布局
extension CFEmoticonKeyboardView {
    private func setupUI()  {
        addSubview(collectionView)
        addSubview(toolbar)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        let viewDict = ["cv": collectionView, "tb": toolbar]
    
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[cv]-0-|", options: [], metrics: nil, views: viewDict))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[tb]-0-|", options: [], metrics: nil, views: viewDict))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[cv]-[tb(44)]-0-|", options: [], metrics: nil, views: viewDict))
        
        prepareToolbar()
        prepareCollectionView()
    }
    
    private func prepareToolbar() {
        toolbar.tintColor = UIColor.lightGrayColor()
        toolbar.barTintColor = UIColor ( red: 0.902, green: 0.902, blue: 0.902, alpha: 1.0 )
        
        var items = [UIBarButtonItem]()
        //  通过 tag 值区别 toolbar 上的按钮
        var index = 0
        for package in emoticonVM.packages {
            let barButtonItem = UIBarButtonItem(title: package.group_name_cn, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CFEmoticonKeyboardView.clickItem(_:)))
            barButtonItem.tag = index
            index += 1
            items.append(barButtonItem)
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
        }
        items.removeLast()
        toolbar.items = items
        
    }
    
    private func prepareCollectionView() {
        //  1. 注册 cell
        collectionView.registerClass(CFEmoticonCell.self, forCellWithReuseIdentifier: kEmoticonCellIdentifier)
        //  2. 指定数据源
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.pagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false

    }
    
}

// MARK: - 监听方法
extension CFEmoticonKeyboardView {
    @objc private func clickItem(item: UIBarButtonItem) {
        
        let indexPath = NSIndexPath(forRow: 0, inSection: item.tag)
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: false)
        
    }
}

// MARK: - 代理回调
extension CFEmoticonKeyboardView: UICollectionViewDataSource, UICollectionViewDelegate {
    /// 分组数量
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return emoticonVM.packages.count
    }
    /// 每个分组的数量
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emoticonVM.packages[section].emoticons.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kEmoticonCellIdentifier, forIndexPath: indexPath) as! CFEmoticonCell
        
        /*
         0 - 0   7 - 1  13 - 2
         1 - 3
         2 - 6
         line
         0  1  2  3  4  5  6    7  8  9  10
         row  -----------------------------------------------
         0   |0  3  6  9  12 15 18 | 21 24 27 30
         1   |1  4  7  10 13 16 19 | 22 25 28 31
         2   |2  5  8  11 14 17 20 | 23 26 29 32
         -----------------------------------------------
         
         newlene
         0  1  2  3  4  5  6    7  8  9  10
         newrow  -----------------------------------------------
         0 |0  1  2  3  4  5  6  | 21 24 27 30
         1 |7  8  9  10 11 12 13 | 22 25 28 31
         2 |14 15 16 17 18 19 20 | 23 26 29 32
         -----------------------------------------------
         
         */
        cell.emoticonM = emoticonVM.emoticon(indexPath)

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CFEmoticonCell
        //  执行闭包回调
        if (cell.emoticonM?.isEmpty)! == false {
            selectedEmoticonCallBack(emoticon: cell.emoticonM!)
            //  添加最近表情符号
            emoticonVM.favorite(cell.emoticonM!)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.collectionView.reloadData()
    }
}

// MARK: - EmoticonCell
private let kEmoticonCellIdentifier = "CFEmoticonCell"

private class CFEmoticonCell: UICollectionViewCell {
    /// 表情包对应的表情索引
    var emoticonM: CFEmoticonM? {
        didSet {
            //  设置模型
            emoticonButton.setImage(UIImage(contentsOfFile: emoticonM!.imagePath), forState: UIControlState.Normal)
            emoticonButton.setTitle(emoticonM?.emoji, forState: UIControlState.Normal)

            if emoticonM!.isRemove {
                emoticonButton.setImage(UIImage(named: "compose_emotion_delete"), forState: UIControlState.Normal)
                emoticonButton.setImage(UIImage(named: "compose_emotion_delete_highlighted"), forState: UIControlState.Highlighted)
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(emoticonButton)
        emoticonButton.frame = CGRectInset(bounds, 4, 4)
        emoticonButton.backgroundColor = UIColor.whiteColor()
        emoticonButton.titleLabel?.font = UIFont.systemFontOfSize(32)
        emoticonButton.userInteractionEnabled = false
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 懒加载控件
    private lazy var emoticonButton = UIButton()
}


// MARK: - 表情键盘布局
private class CFEmoticonFlowLayout: UICollectionViewFlowLayout {
    /// 准备布局，第一次使用时被调用，已经完成自动布局。准备布局方法，会在数据（cell个数前）调用，可以在次准备 layout 属性
    private override func prepareLayout() {
        //        print(collectionView)
        super.prepareLayout()
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        
        let w = collectionView!.bounds.width / 7
        itemSize = CGSize(width: w, height: w)
        
        let margin = (collectionView!.bounds.height - 3 * w) - 0.001
        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: margin, right: 0)
        
        scrollDirection = UICollectionViewScrollDirection.Horizontal
    }
}



