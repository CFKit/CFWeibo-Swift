//
//  CFComposeVC.swift
//  CFWeibo
//
//  Created by 成飞 on 16/4/6.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
import SVProgressHUD

private let kStatusTextMaxLength = 100

/// 撰写微博
class CFComposeVC: UIViewController, UITextViewDelegate, CFPictureSelectorVCDelegate {
    /// 工具栏底部约束
    private var toolbarBottomCons: NSLayoutConstraint?
    
    private var pictureSelectorViewYCons: NSLayoutConstraint?
    
    private var pictureSelectorViewHeightCons: NSLayoutConstraint?
    
    /// 创建界面的函数
    override func loadView() {
        view = UIView()
        //  将自动调整 scrollView 的缩进取消
        automaticallyAdjustsScrollViewInsets = false
        
        view.backgroundColor = UIColor.whiteColor()
        self.configNav()
        self.configToolBar()
        self.configTextView()
        self.configPictureView()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //  注册键盘通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CFComposeVC.keyboardChanged(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if pictureSelectorVC.view.hidden == true {
            self.textView.becomeFirstResponder()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - 懒加载控件
        /// 文本标签
    private lazy var textView: UITextView = {
        let textView = UITextView()
        //  允许垂直拖拽
        textView.alwaysBounceVertical = true
        textView.font = UIFont.systemFontOfSize(18)
        textView.delegate = self
        textView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        return textView
    }()
    /// 工具栏
    private lazy var toolbar = UIToolbar()
    /// 占位标签
    private lazy var placeholderLabel: UILabel = UILabel(title: "分享新鲜事儿...", color: UIColor.lightGrayColor(), fontSize: 18)
    /// 长度提示标签
    private lazy var lengthTipLabel: UILabel = UILabel(title: "", color: UIColor.lightGrayColor(), fontSize: 14)
    /// 照片选择控制器
    private lazy var pictureSelectorVC: CFPictureSelectorVC = {
        let vc = CFPictureSelectorVC()
        vc.delegate = self
        return vc
    }()
    
    private lazy var keyboard: CFEmoticonKeyboardView = CFEmoticonKeyboardView { [weak self](emoticon) in
        self!.textView.insertEmoticon(emoticon)
    }


}

// MARK: - setup UI
extension CFComposeVC {
    /// 准备照片视图
    private func configPictureView() {
        //  添加子控制器
        addChildViewController(pictureSelectorVC)
        textView.addSubview(pictureSelectorVC.view)

        //  自动布局
        let cons = pictureSelectorVC.view.ff_AlignInner(type: ff_AlignType.TopCenter, referView: textView, size: CGSize(width: kScreenWidth, height: 0), offset: CGPoint(x: 0, y: 150))
        pictureSelectorViewHeightCons = pictureSelectorVC.view.ff_Constraint(cons, attribute: NSLayoutAttribute.Height)
        pictureSelectorViewYCons = pictureSelectorVC.view.ff_Constraint(cons, attribute: NSLayoutAttribute.Top)
        pictureNumChange(1)
        pictureSelectorVC.view.hidden = true
    }
    
    /// 设置文本视图
    private func configTextView() {
        view.addSubview(textView)

        //  自动布局(toplayoutGuide 能够自动判断顶部的控件(状态栏/navbar))
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        let viewDict: [String : AnyObject] = ["topLayoutGuide": topLayoutGuide,"toolBar": toolbar, "textView": textView]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[textView]-0-|", options: [], metrics: nil, views: viewDict))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[topLayoutGuide]-[textView]-0-[toolBar]", options: [], metrics: nil, views: viewDict))
        //  设置占位标签
        textView.addSubview(placeholderLabel)
        placeholderLabel.frame = CGRect(origin: CGPoint(x: 5, y: 8), size: placeholderLabel.bounds.size)
        
        //  设置长度提示标签
        view.addSubview(lengthTipLabel)
        lengthTipLabel.ff_AlignInner(type: ff_AlignType.BottomRight, referView: textView, size: nil, offset: CGPoint(x: -kStatusCellMargin - 30, y: -8))
        
    }
    
    /// 设置工具栏
    private func configToolBar() {
        
        view.addSubview(toolbar)
        
        toolbar.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        //  设置自动布局
        let cons = toolbar.ff_AlignInner(type: ff_AlignType.BottomLeft, referView: view, size: CGSize(width: kScreenWidth, height: 44))
        toolbarBottomCons = toolbar.ff_Constraint(cons, attribute: NSLayoutAttribute.Bottom)
        
        //  添加按钮
        let itemSettings = [["imageName": "compose_toolbar_picture", "action": "selectPicture"],
                            ["imageName": "compose_mentionbutton_background"],
                            ["imageName": "compose_trendbutton_background"],
                            ["imageName": "compose_emoticonbutton_background", "action": "inputEmoji"],
                            ["imageName": "compose_addbutton_background"]]
        
        var items = [UIBarButtonItem]()
        for dict in itemSettings {

            items.append(UIBarButtonItem(imageName: dict["imageName"]!, target: self, actionName: dict["action"]))
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
        }
        items.removeLast()
        
        toolbar.items = items
        
    }
    
    /// 设置导航栏
    private func configNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CFComposeVC.close))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发送", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CFComposeVC.sendStatus))
        //  禁用发送按钮
        navigationItem.rightBarButtonItem?.enabled = false
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 34))
        let titleLabel = UILabel(title: "发微博", color: UIColor.darkGrayColor(), fontSize: 16)
        let nameLabel = UILabel(title: CFUserAccountVM.sharedUserAccount.userAccount!.name, color: UIColor.lightGrayColor(), fontSize: 14)
        
        navigationItem.titleView = titleView
        titleView.addSubview(titleLabel)
        titleView.addSubview(nameLabel)
        
        titleLabel.ff_AlignInner(type: ff_AlignType.TopCenter, referView: titleView, size: nil)
        nameLabel.ff_AlignInner(type: ff_AlignType.BottomCenter, referView: titleView, size: nil)
        
    }
    
    private func configPictureViewCons() {
        pictureSelectorViewYCons?.constant = textView.contentSize.height < 80 ? 90 : textView.contentSize.height + 21
        configTextViewInset()
        UIView.animateWithDuration(0.2, animations: {
            self.view.layoutIfNeeded()
        })

    }
    
    private func configTextViewInset() {
        //  判断键盘是否弹出
        let bottomInset: CGFloat
        if toolbarBottomCons?.constant != 0 {// 弹出
            bottomInset = 0
        } else {//  未弹出
            //  判断 pictureSelectorVC.view 是否隐藏
            if pictureSelectorVC.view.hidden == true {
                bottomInset = 0
            } else {
                if textView.contentSize.height - (kScreenWidth - 64 - 44) > pictureSelectorViewHeightCons?.constant {
                    bottomInset = (pictureSelectorViewHeightCons?.constant)! + 25
                } else if (textView.contentSize.height - (kScreenWidth - 64 - 44) > 0) {
                    bottomInset = textView.contentSize.height - (kScreenWidth - 64 - 44) + 25
                } else {
                    bottomInset = 0
                }
            }

        }
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)

//        print("--------------------------------------------------")
//        print("frame : \(textView.frame)")
//        print("Size  : \(textView.contentSize)")
//        print("Inset : \(textView.contentInset)")
//        print("ConsY : \(pictureSelectorViewYCons?.constant)")
//        print("Height: \(pictureSelectorViewHeightCons?.constant)")
//
    }

}

// MARK: - 监听方法
extension CFComposeVC {
    @objc private func close() {
        //  关闭键盘
        textView.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @objc private func sendStatus() {
        //  获取带表情符号文本字符串
        let text = textView.emoticonText
        
        //  判断文本长度
        if text.characters.count > kStatusTextMaxLength {
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
            SVProgressHUD.showInfoWithStatus("输入内容过长");
            return
        }
        
        //  发布微博
        CFNetworkTools.sharedTools.sendStatus(text, image: pictureSelectorVC.pictures.last).subscribeNext({ (result) in
            //  刚刚发送成功的微博数据字典
            print(result)
            }, error: { (error) in
                SVProgressHUD.showInfoWithStatus("您的网络不给力，请稍后再试")
                print(error)
            }) { 
                self.close()
        }
    }
    /// 选择照片
    @objc private func selectPicture() {
        textView.resignFirstResponder()
        pictureSelectorVC.view.hidden = false
        configPictureViewCons()

    }
    
    @objc private func inputEmoji() {
        textView.resignFirstResponder()
        textView.inputView = textView.inputView == nil ? keyboard : nil;
        textView.becomeFirstResponder()
    }
    
    /// 键盘变化监听方法
    @objc private func keyboardChanged(notification: NSNotification) {
        
        //  动画曲线 - 7 没有提供文档
        /*
        1. 如果将动画曲线设置为 7， 他会在连续的动画过程中，前一个动画如果没有执行完毕，直接过渡到最后一个动画
        2. 动画使用 7 之后动画时长一律变成 0.5s
         */
        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey]!.integerValue
        
        
        //  获取 frame - OC 中结构体保存在字典中，存成 NSValue
        let rect = notification.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue
        toolbarBottomCons?.constant = rect.origin.y - kScreenHeight
        configTextViewInset()
        
        //  获取动画时长
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        
        UIView.animateWithDuration(duration) {
            //  设置曲线
            UIView.setAnimationCurve(UIViewAnimationCurve.init(rawValue: curve)!)
            self.view.layoutIfNeeded()
        }
        //  调试动画
//        let anim = toolbar.layer.animationForKey("position")
//        printLog("动画时长：\(anim?.duration)")
    
    }
    

}

// MARK: - 代理回调
extension CFComposeVC {
    // MARK: -- UITextViewDelegate
    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = textView.hasText()
        navigationItem.rightBarButtonItem?.enabled = textView.hasText()
        configPictureViewCons()
        
        //  修改文字长度提示
        let len = kStatusTextMaxLength - textView.emoticonTextLength
        lengthTipLabel.text = String(len)
        lengthTipLabel.textColor = len < 0 ? UIColor.redColor() : UIColor.lightGrayColor()
        
    }
    
    // MARK: -- CFPictureSelectorVCDelegate
    func pictureNumChange(count: Int) {
        let lines = (count + 2) / 3
        let itemWidth = (kScreenWidth - 26) / 3.0
        let height = 16 + itemWidth * CGFloat(lines) + (CGFloat(lines) - 1) * 5
        pictureSelectorViewHeightCons?.constant = height
        
        configTextViewInset()
    }
}
