//
//  CFStatusTopView.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/18.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit


class CFStatusTopView: UIView {

    /// 微博视图模型
    var statusVM: CFStatusVM? {
        didSet {
            //  设置界面属性
            
            iconView.sd_setImageWithURL(statusVM?.userIconURL)
            
            nameLabel.text = statusVM?.status.user?.name

            memberImageView.image = statusVM?.levelImage

            vipImageView.image = statusVM?.userVipImage
            vipImageView.hidden = statusVM?.userVipImage == nil ?  true : false
            
            timeLabel.text = NSDate.sinaDate(statusVM?.status.created_at ?? "")?.dateDescription
            sourceLabel.text = statusVM?.status.source
        }
    }
 
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.whiteColor()
        //  1. 添加控件
        addSubview(iconView)
        addSubview(nameLabel)
        addSubview(memberImageView)
        addSubview(timeLabel)
        addSubview(sourceLabel)
        addSubview(vipImageView)
        //  2. 自动布局
        let offset = CGPoint(x: kStatusCellMargin, y: 0)
        iconView.ff_AlignInner(type: ff_AlignType.TopLeft, referView: self, size: CGSize(width: kStatusIconWidth, height: kStatusIconWidth), offset: CGPoint(x: kStatusCellMargin, y: kStatusCellMargin))
        nameLabel.ff_AlignHorizontal(type: ff_AlignType.TopRight, referView: iconView, size: nil, offset: offset)
        memberImageView.ff_AlignHorizontal(type: ff_AlignType.TopRight, referView: nameLabel, size: nil, offset: offset)
        timeLabel.ff_AlignHorizontal(type: ff_AlignType.BottomRight, referView: iconView, size: nil, offset: offset)
        sourceLabel.ff_AlignHorizontal(type: ff_AlignType.TopRight, referView: timeLabel, size: nil, offset: offset)
        vipImageView.ff_AlignInner(type: ff_AlignType.BottomRight, referView: iconView, size: CGSize(width: 14, height: 14), offset: CGPoint(x: 3, y: 3))

    }
    
    //  MARK: - 懒加载控件
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "avatar_default_big"))
        imageView.layer.cornerRadius = kStatusIconWidth / 2.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    private lazy var nameLabel: UILabel = UILabel(title: nil, color: UIColor.darkGrayColor(), fontSize: 14)
    private lazy var memberImageView: UIImageView = UIImageView(image: UIImage(named: "common_icon_membership"))
    private lazy var timeLabel: UILabel = UILabel(title: "", color: UIColor ( red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0 ), fontSize: 11)
    private lazy var sourceLabel: UILabel = UILabel(title: "", color: UIColor ( red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0 ), fontSize: 11)
    private lazy var vipImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "avatar_grassroot"))
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.whiteColor().CGColor
        imageView.layer.cornerRadius = 7
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
}
