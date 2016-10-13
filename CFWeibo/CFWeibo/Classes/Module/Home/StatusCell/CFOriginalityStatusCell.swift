//
//  CFOriginalityStatusCell.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/29.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
/// 原创微博
let kOriginalityStatusIdentifier = "CFOriginalityStatusCell"

/// 原创微博cell
class CFOriginalityStatusCell: CFStatusCell {
    override func setupUI() {
        super.setupUI()
        pictureView.backgroundColor = UIColor.white
        
        //  记录约束
        pictureView.snp.makeConstraints { (make) in
            make.left.equalTo(contentLabel)
            pictureViewTopCons = make.top.equalTo(contentLabel.snp.bottom).offset(kStatusCellMargin).constraint
            pictureViewWidthCons = make.width.equalTo(kStatusPictureMaxWidth).constraint
            pictureViewHeightCons = make.height.equalTo(kStatusPictureMaxWidth).constraint
        }
    }
}
