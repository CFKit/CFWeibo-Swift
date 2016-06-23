//
//  CFForwardStatusCell.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/29.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
/// 转发微博
let kForwardStatusCellIdentifier = "CFForwardStatusCell"

class CFForwardStatusCell: CFStatusCell {
    
    /// 重新父类微博视图模型(不需要 super 父类的 didset 任然能正常执行)
    override var statusVM: CFStatusVM? {
        didSet {
            //  微博正文
            let statusText = statusVM?.status.text ?? ""
            forwardLabel.attributedText = CFEmoticonVM.sharedEmoticonVM.emoticonText(statusText, font: forwardLabel.font)
        }
    }
    
    
    override func setupUI() {
        super.setupUI()
        
        pictureView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        //  添加控件，加背景图片
        contentView.insertSubview(backButton, belowSubview: pictureView)
        contentView.insertSubview(forwardLabel, aboveSubview:backButton)
        
        //  1. 北京按钮
        backButton.ff_AlignVertical(type: ff_AlignType.BottomLeft, referView: contentLabel, size: nil, offset: CGPoint(x: -kStatusCellMargin, y: kStatusCellMargin))
        backButton.ff_AlignVertical(type: ff_AlignType.TopRight, referView: bottomView, size: nil)
        //  2. 转发文字
        forwardLabel.ff_AlignInner(type: ff_AlignType.TopLeft, referView: backButton, size: nil, offset: CGPoint(x: kStatusCellMargin, y: kStatusCellMargin))
        //  3. 图片视图
        let cons = pictureView.ff_AlignVertical(
            type: ff_AlignType.BottomLeft,
            referView: forwardLabel,
            size: CGSize(width: kStatusPictureMaxWidth, height: kStatusPictureMaxWidth),
            offset: CGPoint(x: 0, y: kStatusCellMargin))
        //  记录约束
        pictureViewWidthCons = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Width)
        pictureViewHeightCons = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Height)
        pictureViewTopCons = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Top)
    }

    
    //  MARK: - 懒加载控件
    /// 背景按钮
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        return button
    } ()
    /// 转发文字
    private lazy var forwardLabel = UILabel(title: "", color: UIColor.darkGrayColor(), fontSize: 14, layoutWidth: kScreenWidth - 2 * kStatusCellMargin)
    
}

//  设置UI
extension CFForwardStatusCell {
}
