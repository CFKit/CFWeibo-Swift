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
    var url: URL?
    
    override func loadView() {
        view = webView
        webView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if url != nil {
            url = URL(string: "http://localhost:8080/struts2-06")
            webView.loadRequest(URLRequest(url: url!))
        }
    }
    
    //  MARK: - 懒加载控件
    lazy var webView = UIWebView()
}

//  MARK: - 代理回调
extension CFHomeWebVC: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        SVProgressHUD.show()
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print(request)
        
        
        
        return true
    }
}

