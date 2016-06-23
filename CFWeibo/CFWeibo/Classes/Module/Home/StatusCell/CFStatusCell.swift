//
//  CFStatusCell.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/18.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
/// 控件间距
let kStatusCellMargin: CGFloat = 12
/// 头像大小
let kStatusIconWidth: CGFloat = 35

let kScreenBounds: CGRect = UIScreen.mainScreen().bounds
/// 屏幕宽度
let kScreenWidth: CGFloat = UIScreen.mainScreen().bounds.width
/// 屏幕高度
let kScreenHeight: CGFloat = UIScreen.mainScreen().bounds.height
/// 微博图片默认大小
let kStatusPictureItemWidth: CGFloat = 112
/// 微博图片默认间距
let kStatusPictureItemMargin: CGFloat = 5
/// 每行最大图片数量
let kStatusPictureMaxCount: CGFloat = 3
/// 配图视图的最大尺寸
let kStatusPictureMaxWidth = kStatusPictureMaxCount * (kStatusPictureItemWidth + kStatusPictureItemMargin) - kStatusPictureItemMargin

/// 微博 cell
class CFStatusCell: UITableViewCell {
    /// 微博数据视图模型
    var statusVM: CFStatusVM? {
        didSet {
            //  模型数值被设置之后，马上要产生的连锁反应 - 界面 UI 发生变化
            topView.statusVM = statusVM
            let statusText = statusVM?.status.text ?? ""
            contentLabel.attributedText = CFEmoticonVM.sharedEmoticonVM.emoticonText(statusText, font: contentLabel.font)
            
            pictureView.statusVM = statusVM
            pictureViewWidthCons?.constant = pictureView.bounds.width
            pictureViewHeightCons?.constant = pictureView.bounds.height
            pictureViewTopCons?.constant = statusVM?.thumbnailURLs?.count == 0 ? 0 : kStatusCellMargin
            
            
            //  在自动布局系统中，随机表格动态修改约束，使用自动计算行高很容易出现问题
//            pictureViewHeightCons?.constant = CGFloat(random() % 3) * kstatusPictureItemWidth
            
        }
    }
    /// CFStatusPictureView 宽度约束
    var pictureViewWidthCons: NSLayoutConstraint?
    /// CFStatusPictureView 高度约束
    var pictureViewHeightCons: NSLayoutConstraint?
    /// CFStatusPictureView 顶部约束
    var pictureViewTopCons: NSLayoutConstraint?

    
    /// 计算行高
    ///
    /// - parameter viewModel: viewModel
    ///
    /// - returns: 行高
    func rowHeitht(viewModel: CFStatusVM) -> CGFloat {
        //  设置视图模型 - 会调用模型的 didset
        statusVM = viewModel
        //  更新约束
        layoutIfNeeded()
        
        return CGRectGetMaxY(bottomView.frame)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = UITableViewCellSelectionStyle.None
        
        setupUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        //  顶部分割视图
        backgroundColor = UIColor.whiteColor()
        let topSepView = UIView()
        topSepView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        contentView.addSubview(topSepView)
        contentView.addSubview(topView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(pictureView)
        contentView.addSubview(bottomView)
        
        //  1> 顶部分割视图
        topSepView.ff_AlignInner(
            type: ff_AlignType.TopLeft,
            referView: contentView,
            size: CGSize(width: kScreenWidth, height: 10))
        //  2> 顶部视图
        topView.ff_AlignVertical(
            type: ff_AlignType.BottomLeft,
            referView: topSepView,
            size: CGSize(width: kScreenWidth, height: kStatusIconWidth + kStatusCellMargin))
        
        //        topView.ff_AlignInner(type: ff_AlignType.TopLeft, referView: contentView, size: CGSize(width: kScreenWidth, height: kStatusCellMargin + kStatusIconWidth), offset: CGPoint(x: 0, y: 10))
        
        //  3> 文本标签
        contentLabel.ff_AlignVertical(
            type: ff_AlignType.BottomLeft,
            referView: topView, size: nil,
            offset: CGPoint(x: kStatusCellMargin, y: kStatusCellMargin))
        
        //  4> 图片视图
//        let cons = pictureView.ff_AlignVertical(
//            type: ff_AlignType.BottomLeft,
//            referView: contentLabel,
//            size: CGSize(width: kStatusPictureMaxWidth, height: kStatusPictureMaxWidth),
//            offset: CGPoint(x: 0, y: kStatusCellMargin))
//        //  记录约束
//        pictureViewWidthCons = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Width)
//        pictureViewHeightCons = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Height)
//        pictureViewTopCons = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Top)
        
        //  5> 底部视图
        bottomView.ff_AlignVertical(
            type: ff_AlignType.BottomLeft,
            referView: pictureView,
            size: CGSize(width: kScreenWidth, height: 34),
            offset: CGPoint(x: -kStatusCellMargin, y: kStatusCellMargin))
        
        //  指定底部视图相对底边约束
//        bottomView.ff_AlignInner(
//            type: ff_AlignType.BottomRight,
//            referView: contentView,
//            size: nil)
        
        
    }
    
    //  MARK: - 懒加载控件
    //  1. 顶部视图
    private lazy var topView: CFStatusTopView = CFStatusTopView()
    //  2. 文本视图
    lazy var contentLabel = UILabel(title: nil, color: UIColor.darkGrayColor(), fontSize: 16, layoutWidth: UIScreen.mainScreen().bounds.width - 2 * kStatusCellMargin)
    //  3. 图片视图
    lazy var pictureView: CFStatusPictureView = CFStatusPictureView()
    
    //  4. 底部视图
    lazy var bottomView: CFStatusBottomView = CFStatusBottomView()
    
    
}
