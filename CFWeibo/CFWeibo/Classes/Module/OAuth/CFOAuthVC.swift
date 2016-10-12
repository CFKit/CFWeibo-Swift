//
//  CFOAuthVC.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/2.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
import SVProgressHUD

//  OAuth 授权控制器
class CFOAuthVC: UIViewController, UIWebViewDelegate {

    fileprivate lazy var webView = UIWebView()
        
    override func loadView() {
        //  跟视图就是 webView
        view = webView
        title = "登陆新浪微博"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CFOAuthVC.close))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "自动填充", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CFOAuthVC.autoFill))
    }
    
    @objc fileprivate func close () {
        SVProgressHUD.dismiss()
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func closeBlock(_ flag: Bool, completion: (() -> Void)?) {
        SVProgressHUD.dismiss()
        dismiss(animated: flag, completion: completion)
    }
    
    @objc fileprivate func autoFill() {
        let js = "document.getElementById('userId').value = 'chengf_0224@163.com';" + "document.getElementById('passwd').value = 'Cf19910224'"
        //  执行 js 脚本
        webView.stringByEvaluatingJavaScript(from: js)
    }

    
    //  尽量让控制器不要管太多事情
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        webView.loadRequest(URLRequest(url: CFNetworkTools.sharedTools.oauthUrl as URL))
        
        webView.delegate = self
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let urlString = request.url!.absoluteString;

        if urlString.hasPrefix(CFNetworkTools.sharedTools.redirectUri) {
            //  query 是 URL 中 ? 后面的内容 检查字符串判断是否有 'code='
            if let query = request.url!.query , query.hasPrefix("code=") {
                let code = query.substring(from: "code=".endIndex)
//                printLog("授权码 \(code)")
                //  调用网络方法，获取 token
                //      1. 服务端会设置 token 的有效期 。 开发者：5年。普通用户：3天。
                //      2. 所有的第三方授权都是‘有限’的。不会产生破坏或者经济相关的问题。
                //  创建用户账户模型  as 将一个对象视为什么类型 !/? 取决于参数的需求
                //  let account = UserAccount(dict: result as! [String: AnyObject])
                
                CFUserAccountVM.sharedUserAccount.loadUserAccount(code).subscribeError({ (error) -> Void in
                    printLog(error)
                    }, completed: { () -> Void in
                        
                        self.closeBlock(false, completion: { () -> Void in
                            NotificationCenter.default.post(name: CFSwitchRootVCNotification, object: "CFWelcomeVC")
                        })
                        
                })
                
            } else {
                print("取消 \(urlString)")
            }
            
            return false
        }
        
        return true
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        SVProgressHUD.show()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
}
