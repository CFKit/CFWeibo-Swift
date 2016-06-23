//
//  CFStatus.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/16.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit

class CFStatus: NSObject {
    /// 微博创建时间
    var created_at: String?
    
    ///  微博ID
    var id: Int = 0
    
    ///  微博信息内容
    var text: String?
    
    ///  微博来源
    var source: String? {
        didSet {
            //  一旦 source 上设置数值后，立即提取，文本链接并且保存
            if let text = source?.href()?.text {
                source = "来自" + text
            } else {
                source = ""
            }
        }
    }
    
    /// 配图 url 字符串数组
    var pic_urls: [[String: String]]?
    
    /// 中等大小图片地址
    var bmiddle_pic: String?
    /// 原始图片地址
    var original_pic: String?
    
    /// 用户模型
    var user: CFUser?
    
    /// 被转发的原创微博对象
    var retweeted_status: CFStatus?
    
    // MARK: - 构造函数
    //  NSArray & NSDictionary 在 Swift 中极少用， contentOfFile 加载 plist 才会使用
    init(dict: [String: AnyObject]) {
        super.init()
        
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forKey key: String) {
        super.setValue(value, forKey: key)
        if key == "user" {
            //  调用其他的构造函数
            user = CFUser(dict: value as! [String: AnyObject])
        }
        if key == "retweeted_status" {
            retweeted_status = CFStatus(dict: value as! [String : AnyObject])
        }

    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
    override var description: String {
        let keys = ["created_at", "id", "text", "source", "pic_urls", "retweeted_status"]
        return dictionaryWithValuesForKeys(keys).description
    }
    
}
