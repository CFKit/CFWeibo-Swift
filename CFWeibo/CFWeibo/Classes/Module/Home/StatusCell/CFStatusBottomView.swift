//
//  CFStatusBottomView.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/18.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit

class CFStatusBottomView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        //  设置背景颜色
        backgroundColor = UIColor(white: 0.97, alpha: 1)
        
        //  设置分割线
        let topLine = UIView()
        let bottomLine = UIView()
        let bottomLine2 = UIView()
        topLine.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        bottomLine.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        bottomLine2.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        
        addSubview(topLine)
        addSubview(forwarButton)
        addSubview(commonButton)
        addSubview(likeButton)
        addSubview(bottomLine)
        addSubview(bottomLine2)
        
        ff_HorizontalTile([forwarButton, commonButton, likeButton], insets: UIEdgeInsetsZero)
        topLine.ff_AlignInner(type: ff_AlignType.TopLeft, referView: self, size: CGSize(width: kScreenWidth, height: 1))
        bottomLine.ff_AlignInner(type: ff_AlignType.TopLeft, referView: bottomLine, size: CGSize(width: kScreenWidth, height: 0.5))
        bottomLine2.ff_AlignInner(type: ff_AlignType.BottomLeft, referView: self, size: CGSize(width: kScreenWidth, height: 0.5))
    }
    
    private lazy var forwarButton = UIButton(title: " 转发", imageName: "timeline_icon_retweet", color: UIColor.darkGrayColor(), fontSize: 12)
    
    private lazy var commonButton = UIButton(title: " 评论", imageName: "timeline_icon_comment", color: UIColor.darkGrayColor(), fontSize: 12)
    
    private lazy var likeButton = UIButton(title: " 赞", imageName: "timeline_icon_unlike", color: UIColor.darkGrayColor(), fontSize: 12)
}

