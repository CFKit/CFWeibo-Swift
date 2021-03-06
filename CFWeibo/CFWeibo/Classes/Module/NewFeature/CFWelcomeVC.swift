//
//  CFWelcomeVC.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/11.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
import SDWebImage
import SnapKit

class CFWelcomeVC: UIViewController {
    //  头像底部约束
    fileprivate var iconBottomCons: Constraint?
    
    fileprivate var iconBottomConsNum: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        //  设置用户头像
        iconImageView.sd_setImage(with: CFUserAccountVM.sharedUserAccount.avatarURL as URL!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //  开始动画
        //  计算目标的约束数值
        let h = -(UIScreen.main.bounds.height + iconBottomConsNum)
        //  修改约束数值. 一旦使用了自动布局。就不要在直接设置 frame
        //  自动布局系统会手机界面上所有需要重新调整 位置/大小 的空间约束
        //  如果开发中需要强行更新约束，可以直接调用 layoutIfNeed 方法，会将当前所有的约束变化应用到控件上
        iconBottomCons?.update(offset: h)
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: [], animations: { () -> Void in
            self.view.layoutIfNeeded()
            
            }) { (_) -> Void in
                UIView.animate(withDuration: 0.8, animations: { () -> Void in
                    self.welcomeLabel.alpha = 1
                    }, completion: {(_) -> Void in
                        //  更新控制器
//                        UIApplication.sharedApplication().keyWindow?.rootViewController = MainViewController()
                        //  利用通知更改根控制器
                        NotificationCenter.default.post(name: CFSwitchRootVCNotification, object: "CFMainVC")
                        
                })
        }
    }
    
    fileprivate func setupUI() {
        view.addSubview(backImageView)
        view.addSubview(iconImageView)
        view.addSubview(welcomeLabel)
        
        backImageView.snp.makeConstraints { (make) in
            make.size.equalTo(view)
            make.center.equalTo(view);
        }

        iconImageView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 90, height: 90))
            make.centerX.equalTo(view)
            iconBottomCons = make.bottom.equalTo(view).offset( -UIScreen.main.bounds.height * 0.3).constraint
            iconBottomConsNum = -UIScreen.main.bounds.height * 0.3
        }
        
        welcomeLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(iconImageView)
            make.top.equalTo(iconImageView.snp.bottom).offset(16 + welcomeLabel.bounds.size.height)
        }
        
//        backImageView.translatesAutoresizingMaskIntoConstraints = false;
//        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[v]-0-|", options: [], metrics:nil, views: ["v": backImageView]))
//        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[v]-0-|", options: [], metrics: nil, views: ["v": backImageView]))

//        iconImageView.translatesAutoresizingMaskIntoConstraints = false;
//        view.addConstraint(NSLayoutConstraint(item: iconImageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0))
////        self.iconBottomCons = NSLayoutConstraint(item: iconImageView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -UIScreen.mainScreen().bounds.height * 0.3)
////        view.addConstraint(self.iconBottomCons!)
//        //  记录垂直方向的约束。将新建的约束添加到视图的约束数组中
//        view.addConstraint( NSLayoutConstraint(item: iconImageView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -UIScreen.mainScreen().bounds.height * 0.3))
//        self.iconBottomCons = view.constraints.last        
        
//        //  设定头像的宽高约束
//        view.addConstraint(NSLayoutConstraint(item: iconImageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 90))
//        view.addConstraint(NSLayoutConstraint(item: iconImageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 90))
//    
//        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addConstraint(NSLayoutConstraint(item: welcomeLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0))
//        view.addConstraint(NSLayoutConstraint(item: welcomeLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: iconImageView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 16))
        
    }
    
    
    //  MARK: - 懒加载控件
    fileprivate lazy var backImageView = UIImageView(image: UIImage(named: "ad_background"))
    fileprivate lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "avatar_default_big"))
        imageView.layer.cornerRadius = 45
        imageView.layer.masksToBounds = true
        
        
        return imageView
    } ()
    
    
//    private lazy var welcomeLabel = UILabel(title: "欢迎归来", color: UIColor.darkGrayColor(), fontSize: 18)
    fileprivate lazy var welcomeLabel: UILabel = {
        let label = UILabel(title: "欢迎归来", color: UIColor.darkGray, fontSize: 18)
        label.alpha = 0
        return label
    } ()
    
}
