//
//  CFForwardStatusCell.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/29.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
import SnapKit
/// 转发微博
let kForwardStatusCellIdentifier = "CFForwardStatusCell"

class CFForwardStatusCell: CFStatusCell {
    
    /// 重新父类微博视图模型(不需要 super 父类的 didset 任然能正常执行)
    override var statusVM: CFStatusVM? {
        didSet {
            //  微博正文
            let statusText = statusVM?.forwardText ?? ""
            
            forwardLabel.attributedText = CFEmoticonVM.sharedEmoticonVM.emoticonText(statusText, font: forwardLabel.font)
        }
    }
    
    
    override func setupUI() {
        super.setupUI()
        
        pictureView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        //  添加控件，加背景图片
        contentView.insertSubview(backButton, belowSubview: pictureView)
        contentView.insertSubview(forwardLabel, aboveSubview:backButton)
        //  1. 背景按钮
        backButton.snp.makeConstraints { (make) in
            make.top.equalTo(contentLabel.snp.bottom).offset(kStatusCellMargin)
            make.left.equalTo(contentLabel.snp.left).offset(-kStatusCellMargin)
            make.bottom.equalTo(bottomView.snp.top)
            make.right.equalTo(bottomView.snp.right)
        }
        //  2. 转发文字
        forwardLabel.snp.makeConstraints { (make) in
            make.top.equalTo(backButton.snp.top).offset(kStatusCellMargin)
            make.left.equalTo(backButton.snp.left).offset(kStatusCellMargin)
        }
        //  3. 图片视图
        pictureView.snp.makeConstraints { (make) in
            make.left.equalTo(forwardLabel)
            pictureViewTopCons = make.top.equalTo(forwardLabel.snp.bottom).offset(kStatusCellMargin).constraint
            pictureViewWidthCons = make.width.equalTo(kStatusPictureMaxWidth).constraint
            pictureViewHeightCons = make.height.equalTo(kStatusPictureMaxWidth).constraint
        }
    }

    
    //  MARK: - 懒加载控件
    /// 背景按钮
    fileprivate lazy var backButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        return button
    } ()
    /// 转发文字
    fileprivate lazy var forwardLabel: FFLabel = {
        let label = FFLabel()
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.preferredMaxLayoutWidth = kScreenWidth - 2 * kStatusCellMargin
        label.numberOfLines = 0
        label.labelDelegate = self;
        
        return label
    } ()

    
}

//  设置UI
extension CFForwardStatusCell {
}
