//
//  CFVisitorLoginView.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/1.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
//protocol VisitorLoginViewDelegate: NSObjectProtocol {
//    
//    func visitorLoginViewWillRegister();
//    func visitorLoginViewWillLogin();
//
//}


class CFVisitorLoginView: UIView {
    //  定义代理
//    weak var delegate: VisitorLoginViewDelegate?
    
//    @objc private func clickRegister() {
//        delegate?.visitorLoginViewWillRegister()
//    }
//    
//    @objc private func clickLogin() {
//        delegate?.visitorLoginViewWillLogin()
//    }

    
    /// 设置界面信息
    ///
    /// - parameter message:   消息文字
    /// - parameter imageName: 图像名称
    func setupInfo(message: String, imageName: String?) {
        messageLabel.text = message;
        //  判断是否传递图片，有图片就不是首页
        
        if let imgName: String = imageName {
            iconView.image = UIImage(named: imgName)
            homeIconView.hidden = true
            //  将 iconView 移动到顶部
            bringSubviewToFront(iconView)
            //  将 maskImageView 移动到底部
            sendSubviewToBack(maskImageView)
        } else {
            stratAnimation()
        }
    }
    /// 首页图标的动画
    private func stratAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.toValue = 2 * M_PI
        animation.duration = 10
        animation.repeatCount = MAXFLOAT
        //  设置动画不被删除，当 iconView 被销毁的时候，动画会被自动释放
        animation.removedOnCompletion = false
        iconView.layer.addAnimation(animation, forKey: nil)
    }
    
    /// 纯代码开发会被调用
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI();
    }
    
    /// storyboard 开发被调用
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupUI();

    }
    
    //  MARK: - 懒加载控件 -> 负责创建界面
    //  图标
    private lazy var iconView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_image_smallicon"))
    
    //  小房子
    private lazy var homeIconView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_image_house"))
    //  遮罩视图
    private lazy var maskImageView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_mask_smallicon"))
    
    //  消息文字
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "关注一些人，回这里看看有什么惊喜关注一些人，回这里看看有什么惊喜。"
        label.textColor = UIColor.darkGrayColor()
        label.font = UIFont.systemFontOfSize(14)
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignment.Center

        return label
    } ()
    //  注册按钮
    lazy var registerButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("注册", forState: UIControlState.Normal)
        btn.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
        btn.setBackgroundImage(UIImage(named: "common_button_white_disable"), forState: UIControlState.Normal)
//        btn.addTarget(self, action: "clickRegister", forControlEvents: UIControlEvents.TouchUpInside)

        return btn
    } ()
    
    //  登陆按钮
    lazy var loginButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("登陆", forState: UIControlState.Normal)
        btn.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        btn.setBackgroundImage(UIImage(named: "common_button_white_disable"), forState: UIControlState.Normal)
//        btn.addTarget(self, action: "clickLogin", forControlEvents: UIControlEvents.TouchUpInside)
        return btn
    } ()

    /// 设置界面  -> 负责添加和设置界面位置
    //  MARK: - 界面布局
    private func setupUI() {
        backgroundColor = UIColor(white: 237.0 / 255.0, alpha: 1)
        //  添加控件
        addSubview(iconView)
        addSubview(maskImageView)
        addSubview(homeIconView)
        addSubview(messageLabel)
        addSubview(registerButton)
        addSubview(loginButton)
        
        //  设置布局，将布局添加到视图上(view1.attr1 = view2.attr2 * multiplier + constant)
        //  默认情况下，使用纯代码开发不支持自动布局，如果支持需要将 translatesAutoresizingMaskIntoConstraints 设置为 false/no
        //  1> 图标
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: iconView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: iconView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: -50))
        //  2> 小房子
        homeIconView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: homeIconView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: iconView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: homeIconView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: iconView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        //  3> 消息
        let labelWidth = UIScreen.mainScreen().bounds.width * 0.6 - UIScreen.mainScreen().bounds.width * 0.6 % 14;
        messageLabel.translatesAutoresizingMaskIntoConstraints = false;
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: iconView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: iconView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 16))
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0, constant: labelWidth))
        
        //  如果要设置一个固定值，参照的属性，需要设置为 NSLayoutAttribute.NotAnAttribute ， 参照对象是 nil
        //        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0, constant: 224))
        //  4> 注册按钮
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: registerButton, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: messageLabel, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: -10))
        addConstraint(NSLayoutConstraint(item: registerButton, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: messageLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 16))
        addConstraint(NSLayoutConstraint(item: registerButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: messageLabel, attribute: NSLayoutAttribute.Width, multiplier: 0.5, constant: -15))
        addConstraint(NSLayoutConstraint(item: registerButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0, constant: 35))
        
        //  5> 登陆按钮
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: messageLabel, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 10))
        addConstraint(NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: messageLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 16))
        addConstraint(NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: messageLabel, attribute: NSLayoutAttribute.Width, multiplier: 0.5, constant: -15))
        addConstraint(NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0, constant: 35))
        //  6> 遮罩视图(- VFL 可视化布局语言) H: 水平 V: 垂直 |: 边界 [] 控件 metrics 极少用
        maskImageView.translatesAutoresizingMaskIntoConstraints = false
        //        let cons = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[v]-0-|", options: [], metrics: nil, views: ["v": maskImageView])
        //        print(cons)
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[v]-0-|", options: [], metrics: nil, views: ["v": maskImageView]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[v]-(-35)-[btn]", options: [], metrics: nil, views: ["v": maskImageView, "btn": loginButton]))
    
        
    }

}
