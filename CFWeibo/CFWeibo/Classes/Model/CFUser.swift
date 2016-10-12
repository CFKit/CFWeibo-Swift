
//
//  CFUser.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/18.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit

class CFUser: NSObject {
 /// 用户id
    var id: Int = 0
 /// 好友名称
    var name: String?
 /// 用户头像地址(50*50)
    var profile_image_url: String?
 /// 认证类型  没有认证：-1，认证用户：0，企业认证:2，3，5，达人：220
    var verified: Int = 0
 /// 会员等级 1-6
    var mbrank: Int = 0
    
    
    
    // MARK: - 构造函数
    //  NSArray & NSDictionary 在 Swift 中极少用， contentOfFile 加载 plist 才会使用
    init(dict: [String: AnyObject]) {
        super.init()
        
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
    
    override var description: String {
        let keys = ["id", "name", "profile_image_url", "verified", "mbrank"]
        return dictionaryWithValues(forKeys: keys).description
    }

    
}
