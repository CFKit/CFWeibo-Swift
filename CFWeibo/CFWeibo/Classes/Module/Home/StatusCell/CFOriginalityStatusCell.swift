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
        pictureView.backgroundColor = UIColor.whiteColor()
        
        let cons = pictureView.ff_AlignVertical(
            type: ff_AlignType.BottomLeft,
            referView: contentLabel,
            size: CGSize(width: kStatusPictureMaxWidth, height: kStatusPictureMaxWidth),
            offset: CGPoint(x: 0, y: kStatusCellMargin))
        //  记录约束
        pictureViewWidthCons = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Width)
        pictureViewHeightCons = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Height)
        pictureViewTopCons = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Top)
    }
}
