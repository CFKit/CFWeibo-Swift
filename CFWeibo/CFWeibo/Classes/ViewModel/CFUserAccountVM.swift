//
//  CFUserAccountVM.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/7.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
import ReactiveCocoa

/// 用户账户视图模型
class CFUserAccountVM: NSObject {

    static let sharedUserAccount = CFUserAccountVM()
    
    override init() {
        userAccount = CFUserAccount.loadUserAccount()
    }
    
    
    /// 用户账户
    var userAccount: CFUserAccount?
    
    var accessToken: String? {
        return userAccount?.access_token
    }
    
    /// 用户登录标记
    var userLogin: Bool {
        return accessToken != nil
    }
    
    var avatarURL: URL? {
        return URL(string: userAccount?.avatar_large ?? "")
    }

    
    // MARK: - 加载网络数据
    
    func loadUserAccount(_ code: String) -> RACSignal {
        
        return RACSignal.createSignal({ (subscriber) -> RACDisposable! in
            
            //  doNext 是可以给信号增加附加操作，第一个信号完成之后，将第一个信号的 result 直接传递给第二个信号
            //  doNext 后面一定要加一个 subscriberXXX 否则 doNext 不会被执行到
            CFNetworkTools.sharedTools.loadAccessToken(code).doNext({ (result) -> Void in
                
//                printLog(result);
                
                //  创建用户账户模型  as 将一个对象视为什么类型 !/? 取决于参数的需求
                let account = CFUserAccount(dict: result as! [String: AnyObject])
                //  设置属性
                self.userAccount = account
                
                
                 CFNetworkTools.sharedTools.loadUserInfo(account.uid!).subscribeNext({ (result) -> Void in

                    //  设置账号属性
                    let dict = result as! [String: AnyObject]
                    account.name = dict["name"] as? String
                    account.avatar_large = dict["avatar_large"] as? String
                    
//                    printLog(account)
                    account.saveUserAccount()

                    //  直接通知订阅者网络数据加载完成
                    subscriber?.sendCompleted()

                    }, error: { (error) -> Void in
                        subscriber?.sendError(error)
                })

            }).subscribeError({ (error) -> Void in
                subscriber?.sendError(error)
            })
            
            return nil
        })

    }
    
}
