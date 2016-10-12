//
//  CFEmoticonKeyboardVC.swift
//  14. 表情键盘
//
//  Created by 成飞 on 16/4/20.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit

let maxRow = 3
let maxLine = 7

class CFEmoticonKeyboardVC: UIViewController {
    
    var selectedEmoticonCallBack: (_ emoticon: CFEmoticonM)->()
    init(selectedEmoticon: @escaping (_ emoticon: CFEmoticonM) -> ()) {
        
        selectedEmoticonCallBack = selectedEmoticon
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - 懒加载控件
        /// 工具栏
    fileprivate lazy var toolbar = UIToolbar()
        /// collectionView
    fileprivate lazy var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: CFEmoticonFlowLayout())
        /// 表情包的视图模型
    fileprivate lazy var emoticonVM = CFEmoticonVM.sharedEmoticonVM
}

// MARK: - 页面布局
extension CFEmoticonKeyboardVC {
    fileprivate func setupUI()  {
        view.addSubview(collectionView)
        view.addSubview(toolbar)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        let viewDict = ["cv": collectionView, "tb": toolbar] as [String : Any]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cv]-0-|", options: [], metrics: nil, views: viewDict))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tb]-0-|", options: [], metrics: nil, views: viewDict))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[cv]-[tb(44)]-0-|", options: [], metrics: nil, views: viewDict))
        
        prepareToolbar()
        prepareCollectionView()
    }
    
    fileprivate func prepareToolbar() {
        toolbar.tintColor = UIColor.lightGray
        toolbar.barTintColor = UIColor ( red: 0.902, green: 0.902, blue: 0.902, alpha: 1.0 )
        
        var items = [UIBarButtonItem]()
        //  通过 tag 值区别 toolbar 上的按钮
        var index = 0
        for package in emoticonVM.packages {
            let barButtonItem = UIBarButtonItem(title: package.group_name_cn, style: UIBarButtonItemStyle.plain, target: self, action: #selector(CFEmoticonKeyboardVC.clickItem(_:)))
            barButtonItem.tag = index
            index += 1
            items.append(barButtonItem)
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil))
        }
        items.removeLast()
        toolbar.items = items
        
    }

    fileprivate func prepareCollectionView() {
        //  1. 注册 cell
        collectionView.register(CFEmoticonCell.self, forCellWithReuseIdentifier: kEmoticonCellIdentifier)
        //  2. 指定数据源
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.backgroundColor = UIColor.white
        
    }

}

// MARK: - 监听方法
extension CFEmoticonKeyboardVC {
    @objc fileprivate func clickItem(_ item: UIBarButtonItem) {

        let indexPath = IndexPath(row: 0, section: item.tag)
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: false)
        
    }
}

// MARK: - 代理回调
extension CFEmoticonKeyboardVC: UICollectionViewDataSource, UICollectionViewDelegate {
    /// 分组数量
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return emoticonVM.packages.count
    }
    /// 每个分组的数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emoticonVM.packages[section].emoticons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kEmoticonCellIdentifier, for: indexPath) as! CFEmoticonCell

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
        let page = (indexPath as NSIndexPath).row / (maxRow * maxLine)
        let pageCount = (indexPath as NSIndexPath).row % (maxRow * maxLine)
        
        let index = pageCount % maxRow * maxLine + pageCount / maxRow + page * maxLine * maxRow

        let newIndexPath = IndexPath(row: index, section: (indexPath as NSIndexPath).section)
        
        cell.emoticonM = emoticonVM.emoticon(newIndexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CFEmoticonCell
        //  执行闭包回调
        if (cell.emoticonM?.isEmpty)! == false {
            selectedEmoticonCallBack(cell.emoticonM!)
        }
    }
    
}

// MARK: - EmoticonCell
private let kEmoticonCellIdentifier = "CFEmoticonCell"

private class CFEmoticonCell: UICollectionViewCell {
        /// 表情包对应的表情索引
    var emoticonM: CFEmoticonM? {
        didSet {
            //  设置模型
            emoticonButton.setImage(UIImage(contentsOfFile: emoticonM!.imagePath), for: UIControlState())
            emoticonButton.setTitle(emoticonM?.emoji, for: UIControlState())
            if emoticonM!.isRemove {
                emoticonButton.setImage(UIImage(named: "compose_emotion_delete"), for: UIControlState())
                emoticonButton.setImage(UIImage(named: "compose_emotion_delete_highlighted"), for: UIControlState.highlighted)
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(emoticonButton)
        emoticonButton.frame = bounds.insetBy(dx: 4, dy: 4)
        emoticonButton.backgroundColor = UIColor.white
        emoticonButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        emoticonButton.isUserInteractionEnabled = false

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 懒加载控件
    fileprivate lazy var emoticonButton = UIButton()
}


// MARK: - 表情键盘布局
private class CFEmoticonFlowLayout: UICollectionViewFlowLayout {
    /// 准备布局，第一次使用时被调用，已经完成自动布局。准备布局方法，会在数据（cell个数前）调用，可以在次准备 layout 属性
    fileprivate override func prepare() {
//        print(collectionView)
        super.prepare()
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0

        let w = collectionView!.bounds.width / 7
        itemSize = CGSize(width: w, height: w)
        
        let margin = (collectionView!.bounds.height - 3 * w) - 0.001
        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: margin, right: 0)
        
        scrollDirection = UICollectionViewScrollDirection.horizontal
        collectionView?.isPagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
    }
}



