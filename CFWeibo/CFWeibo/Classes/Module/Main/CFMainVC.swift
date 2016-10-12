//
//  CFMainVC.swift
//  CFWeibo
//
//  Created by 成飞 on 16/2/29.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit

class CFMainVC: UITabBarController {

    /// 视图加载完成会调用，通常在视图控制器加载完成后，做准备工作，例如：加载数据或者一次性的初始化工作。如果视图没有被销毁只会被调用一次。目前有些开发中会把是创建视图控件的代码放在 viewDidLoad 中
    override func viewDidLoad() {
        super.viewDidLoad()

        ///  添加所有自控制器，不会添加 tabbar 中的按钮，在 iOS 开发中，懒加载是无处不在的，视图资源只有在需要显示的时候，才会被创建
        addChildViewControllers()
    }
    /// 视图将要出现，可能会被调用多次。
    ///
    /// - parameter animated: 是否显示动画
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //  视图将要出现的时候 tabbar 中的按钮才会创建
//        print(tabBar.subviews)
        setupComposedButton()
    }
    /**
     按钮监听方法，由运行循环调用的，因此不能直接使用 private。在 swift 如果不使用 private 修饰，是全局共享的。
     @objc 关键字能够保证运行循环能够调用，走 oc 的消息机制，调用之前不再判断方法是否存在和 private 联用，就能够做到对方法的保护
     */
    @objc fileprivate func clickComposeButton() {
        var vc: UIViewController
        if CFUserAccountVM.sharedUserAccount.userLogin {
            vc = CFComposeVC()
        } else {
            vc = CFOAuthVC()
        }
        vc = CFComposeVC()
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    
    }
    
    /**
     设置撰写按钮位置
     */
    fileprivate func setupComposedButton() {
        //  控制器总数
        let count = childViewControllers.count
        //  计算每个按钮宽度
        let w = tabBar.bounds.width / CGFloat(count)
        let rect = CGRect(x: 0, y: 0, width: w, height: tabBar.bounds.height)
        
        //  设置按钮位置
        composedButton.frame = rect.offsetBy(dx: 2 * w, dy: 0)
    }
    
    /**
     添加所有子控制器
     */
    fileprivate func addChildViewControllers() {
        //  设置 tabbar 的渲染颜色
//        tabBar.tintColor = UIColor.orangeColor()
        
        addChildViewController(CFHomeTableVC(), title: "首页", imageName: "tabbar_home", selectedImageName: "tabbar_home_highlighted")
        addChildViewController(CFMessageTableVC(), title: "消息", imageName: "tabbar_message_center", selectedImageName: "tabbar_message_center_highlighted")
        addChildViewController(UIViewController())
        addChildViewController(CFDiscoverTableVC(), title: "发现", imageName: "tabbar_discover", selectedImageName: "tabbar_discover_highlighted")
        addChildViewController(CFProfileTableVC(), title: "我", imageName: "tabbar_profile", selectedImageName: "tabbar_profile _highlighted")
    }
    

     /// 添加独立自控制器
     ///
     /// - parameter vc:                视图控制器
     /// - parameter title:             title
     /// - parameter imageName:         图像名
     /// - parameter selectedImageName: 选中图像
    fileprivate func addChildViewController(_ vc: UIViewController, title: String, imageName: String, selectedImageName: String) {
        //  设置标题
        vc.title = title
        vc.tabBarItem.image = UIImage(named: imageName)
        vc.tabBarItem.selectedImage = UIImage(named: selectedImageName)
        let nav = UINavigationController(rootViewController: vc)

        //  添加控制器
        addChildViewController(nav)
        
    }
    
    //  MARK: - 懒加载控件
    fileprivate lazy var composedButton: UIButton = {
        //  自定义的 button
        let btn = UIButton()
        btn.setImage(UIImage(named: "tabbar_compose_icon_add"), for: UIControlState())
        btn.setImage(UIImage(named: "tabbar_compose_icon_add_highlighted"), for: UIControlState.highlighted)
        btn.setBackgroundImage(UIImage(named: "tabbar_compose_button"), for: UIControlState())
        btn.setBackgroundImage(UIImage(named: "tabbar_compose_button_highlighted"), for: UIControlState.highlighted)
        //  添加监听方法
        btn.addTarget(self, action: #selector(CFMainVC.clickComposeButton), for: UIControlEvents.touchUpInside)        
        self.tabBar.addSubview(btn)
        
        return btn
    } ()
}
