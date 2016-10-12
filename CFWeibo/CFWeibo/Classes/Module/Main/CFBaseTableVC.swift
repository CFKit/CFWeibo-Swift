//
//  CFBaseTableVC.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/1.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit

//  在 Swift 中，遵守协议直接 , 接着写
class CFBaseTableVC: UITableViewController {//VisitorLoginViewDelegate

    ///  用户登录标记
    var userLogin = CFUserAccountVM.sharedUserAccount.userLogin //UserAccount.loadUserAccount()?.access_token != nil;
    /// 用户登录视图  -- 如果使用懒加载，会在用户登录成功后，视图仍然被创建，虽然不会影响程序执行，但是会消耗内存
    var visitorView: CFVisitorLoginView?
    
    /**
     是苹果专为‘代码创建视图’层次结构设计的函数，可以和 xib/Storyboard 等价
        如果 view 不存在，系统会再次调用 loadView
     */
    override func loadView() {
        userLogin ? super.loadView() : setUpVistorView();
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    fileprivate func setUpVistorView() {
        visitorView = CFVisitorLoginView()
//        visitorView?.delegate = self;
        //  替换根视图
        view = visitorView;
        
        //  设置导航按钮
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CFBaseTableVC.visitorLoginViewWillRegister))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "登录", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CFBaseTableVC.visitorLoginViewWillLogin))
        
        //  设置按钮监听方法
        visitorView?.registerButton.addTarget(self, action: #selector(CFBaseTableVC.visitorLoginViewWillRegister), for: UIControlEvents.touchUpInside)
        visitorView?.loginButton.addTarget(self, action: #selector(CFBaseTableVC.visitorLoginViewWillLogin), for: UIControlEvents.touchUpInside)
    }

    
    @objc fileprivate func visitorLoginViewWillLogin() {
        let nav = UINavigationController(rootViewController: CFOAuthVC())
        
        present(nav, animated: true, completion: nil)
    }
    
    @objc fileprivate func visitorLoginViewWillRegister() {
        print("注册")
    }

}
