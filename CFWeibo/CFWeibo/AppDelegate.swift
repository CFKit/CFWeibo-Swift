 //
//  AppDelegate.swift
//  CFWeibo
//
//  Created by 成飞 on 16/2/23.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
import AFNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //  打印用户账户信息
//        printLog(UserAccountVM.sharedUserAccount.userAccount)
        //  注册通知(object：监听有哪个对象发出的通知)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.switchRootVC(_:)), name: CFSwitchRootVCNotification, object: nil)
        
        setupNetwork()
        setUpAppearance()
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.whiteColor()
        window?.rootViewController = defaultRootViewController()
        window?.makeKeyAndVisible()

        return true
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CFSwitchRootVCNotification, object: nil)
    }
    
    /// 切换控制器通知的监听方法
    func switchRootVC(notification: NSNotification) {
        //  获得类的命名空间
        let nameSpace = NSBundle.mainBundle().infoDictionary!["CFBundleExecutable"]
        guard let name = nameSpace as? String else { return }
        //  拼接命名空间并转为 classtype 注意拼接时必须均为 String 类型。 不能出现可选
        let classVC: AnyClass? = NSClassFromString("\(name).\(notification.object as! String)")
        guard let classType = classVC as? UIViewController.Type else {
            window?.rootViewController = CFMainVC()
            return
        }
        //  创建字符串对应的类
        window?.rootViewController = classType.self.init()

    }

    /**
     修改全局外观
        修改导航栏外观尽量早，一经修改全局有效
     */
    private func setUpAppearance() {
        UINavigationBar.appearance().tintColor = UIColor.orangeColor()
        UITabBar.appearance().tintColor = UIColor.orangeColor()
    }
    
    private func defaultRootViewController() -> UIViewController {
        //  1. 判断用户是否登陆
        if CFUserAccountVM.sharedUserAccount.userLogin {
            //  2. 如果登陆，判断是否有新版本
            return isNewVersion() ? CFNewFeatureVC() : CFWelcomeVC();
        }
        //  3. 如果没有登陆，返回main
        return CFMainVC()
    }
    
    /// 判断是否新版本
    private func isNewVersion() -> Bool {
        let versionKey = "CFBundleShortVersionString"
        //  1. 当前应用程序的版本号
        let bundleVersion = Double(NSBundle.mainBundle().infoDictionary![versionKey] as! String)
        //  2. 之前保存的程序版本号
        let saxboxVersion = NSUserDefaults.standardUserDefaults().doubleForKey(versionKey)
        //  3. 保存当前版本
        NSUserDefaults.standardUserDefaults().setDouble(bundleVersion!, forKey: versionKey)
        
        //  4. 比较两个版本，返回结果
        return bundleVersion > saxboxVersion
    }
    
    //  设置网络指示器
    private func setupNetwork() {
        //  设置网络指示器，一旦设置，发起网络请求，会在状态栏显示菊花，只负责 AFN 的网络请求，其他的网络框架不负责
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true;
        //  设置缓存大小 NSURLCache -> GET 请求的数据会被缓存
    
        // 缓存的磁盘路径： /Library/Caches/(application bundle id)
        //  "/Users/chengfei/Library/Developer/CoreSimulator/Devices/5BE4D0AB-4CC9-4CBF-95CC-CE9B1181F4F9/data/Containers/Data/Application/F3647B80-8F04-466D-A342-E52ECF1DB184"
        //  内存缓存：   memoryCapacity  4M
        //  磁盘缓存：   diskCapacity    20M
        //  提示： URLSession 只用 dataTask 会被缓存。 downloadTask/uploadTask 都不会被缓存
        let cache = NSURLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        NSURLCache.setSharedURLCache(cache)
        
    }
    
}

