//
//  CFStatusTopView.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/18.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
import SnapKit

class CFStatusTopView: UIView {

    /// 微博视图模型
    var statusVM: CFStatusVM? {
        didSet {
            //  设置界面属性
            
            iconView.sd_setImage(with: statusVM?.userIconURL as URL!)
            
            nameLabel.text = statusVM?.status.user?.name

            memberImageView.image = statusVM?.levelImage

            vipImageView.image = statusVM?.userVipImage
            vipImageView.isHidden = statusVM?.userVipImage == nil ?  true : false
            
            timeLabel.text = Date.sinaDate(statusVM?.status.created_at ?? "")?.dateDescription
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
    
    fileprivate func setupUI() {
        backgroundColor = UIColor.white
        //  1. 添加控件
        addSubview(iconView)
        addSubview(nameLabel)
        addSubview(memberImageView)
        addSubview(timeLabel)
        addSubview(sourceLabel)
        addSubview(vipImageView)
        //  2. 自动布局
        iconView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: kStatusIconWidth, height: kStatusIconWidth))
            make.left.equalTo(self).offset(kStatusCellMargin)
            make.top.equalTo(self).offset(kStatusCellMargin)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconView)
            make.left.equalTo(iconView.snp.right).offset(kStatusCellMargin)
        }
        memberImageView.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel)
            make.left.equalTo(nameLabel.snp.right).offset(kStatusCellMargin)
        }
        timeLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(iconView)
            make.left.equalTo(iconView.snp.right).offset(kStatusCellMargin)
        }
        sourceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(timeLabel.snp.right).offset(kStatusCellMargin)
            make.top.equalTo(timeLabel)
        }
        vipImageView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 14, height: 14))
            make.bottom.equalTo(iconView).offset(3)
            make.right.equalTo(iconView.snp.right).offset(3)
        }

    }
    
    //  MARK: - 懒加载控件
    fileprivate lazy var iconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "avatar_default_big"))
        imageView.layer.cornerRadius = kStatusIconWidth / 2.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    fileprivate lazy var nameLabel: UILabel = UILabel(title: nil, color: UIColor.darkGray, fontSize: 14)
    fileprivate lazy var memberImageView: UIImageView = UIImageView(image: UIImage(named: "common_icon_membership"))
    fileprivate lazy var timeLabel: UILabel = UILabel(title: "", color: UIColor ( red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0 ), fontSize: 11)
    fileprivate lazy var sourceLabel: UILabel = UILabel(title: "", color: UIColor ( red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0 ), fontSize: 11)
    fileprivate lazy var vipImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "avatar_grassroot"))
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = 7
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
}
