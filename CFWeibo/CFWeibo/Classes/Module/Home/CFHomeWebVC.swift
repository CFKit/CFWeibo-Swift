//
//  CFHomeWebVC.swift
//  CFWeibo
//
//  Created by 成飞 on 16/6/29.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
import SVProgressHUD


class CFHomeWebVC: UIViewController {
    /// url
    var url: NSURL?
    
    override func loadView() {
        view = webView
        webView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if url != nil {
            webView.loadRequest(NSURLRequest(URL: url!))
        }
    }
    
    //  MARK: - 懒加载控件
    lazy var webView = UIWebView()
}

//  MARK: - 代理回调
extension CFHomeWebVC: UIWebViewDelegate {
    func webViewDidStartLoad(webView: UIWebView) {
        SVProgressHUD.show()
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
}

