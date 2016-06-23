//
//  CFUserAccount.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/4.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit

/// 用户信息
class CFUserAccount: NSObject, NSCoding {

/// 用于调用access_token，接口获取授权后的access token。
    var access_token: String?

/// access_token的生命周期，单位是秒数。对于第三方接口，只能访问有限的资源。
//    开发者 5年 一般用户 3天。 开发过程中需要判断token是否过期，如果过期，需要用户重新登录
    var expires_in: NSTimeInterval = 0 {
        didSet {
            //  计算日期
            expiresDate = NSDate(timeIntervalSinceNow: expires_in)
        }
    }

    var expiresDate: NSDate?;
    
    /// 当前授权用户的UID。
    var uid: String?
    
    ///   友好显示名称
    var name: String?
    
    /// 用户头像地址（大图），180×180像素
    var avatar_large: String?
    
    init(dict: [String: AnyObject]) {
        super.init()
        
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}

    /// 对象的描述信息，需要生写。
    /// 在 swift/OC ，任何对象都有一个 description 的属性，用处就是用来打印对象信息。默认 字典/数组/字符串 都有自己的格式，而自定义对象，默认的格式： <类名：地址> 不利于调试，为了便于调试，自定义对象可以重写 description。
    override var description: String {
        let keys = ["access_token", "expires_in", "expiresDate", "uid", "name", "avatar_large", "verified", "mbrank"]
        //  KVC 的模型转字典 
        //2b6e8c8ed42f4e844e1b1ddb39950061
        //2.00YqQw3GzXn7SD6d0eb71826DNWZOC
        return dictionaryWithValuesForKeys(keys).description
//        "\(dictionaryWithValuesForKeys(keys))"
    }
    
    static let accountPath = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last! as NSString).stringByAppendingPathComponent("account.plist")
    //  将当前对象归档保存
    func saveUserAccount() {
        //  Xcode 7.0 取消了 String 的拼接路径函数，改成 NSString
        printLog("保存路径" + CFUserAccount.accountPath)
        
        NSKeyedArchiver.archiveRootObject(self, toFile: CFUserAccount.accountPath)
    }
    
    /// 加载用户信息
    ///
    /// - returns: 账户信息，如果用户还没有登录，返回 nil
    class func loadUserAccount() -> CFUserAccount? {
        
        //  解档加载用户账户时，需要判断有效期
        let account = NSKeyedUnarchiver.unarchiveObjectWithFile(accountPath) as? CFUserAccount
        
        if let date = account?.expiresDate {
            //  date > NSDate() 结果是降序
            if date.compare(NSDate()) == NSComparisonResult.OrderedDescending {
                return account
            }
        }
        return nil
    }
    
    // MARK: - NSCoding
    //  归档，将当前对象保存到磁盘之前，转换成二进制数据
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(access_token, forKey: "access_token")
        aCoder.encodeObject(expiresDate, forKey: "expiresDate")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(uid, forKey: "uid")
        aCoder.encodeObject(avatar_large, forKey: "avatar_large")
    }
    
    //  解档，将二进制数据从磁盘加载，转换成自定义对象时调用，跟反序列化很像
    required init?(coder aDecoder: NSCoder) {
        access_token = aDecoder.decodeObjectForKey("access_token") as? String
        expiresDate = aDecoder.decodeObjectForKey("expiresDate") as? NSDate
        name = aDecoder.decodeObjectForKey("name") as? String
        uid = aDecoder.decodeObjectForKey("uid") as? String
        avatar_large = aDecoder.decodeObjectForKey("avatar_large") as? String
    }
    
}
