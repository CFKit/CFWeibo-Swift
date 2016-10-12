 //
//  CFStatusDAL.swift
//  CFWeibo
//
//  Created by 成飞 on 16/7/4.
//  Copyright © 2016年 成飞. All rights reserved.
//

import Foundation
import ReactiveCocoa

/// 数据库缓存时间长度
private let kDBCacheDateTime: TimeInterval = 60 // 7 * 24 * 3600
 
class CFStatusDAL {
    /**
        看不到新关注用户的数据，中间会有数据断层，违法的微博
     */
    /// 清除数据库缓存数据（不要将太大的数据存在sql中）
    class func clearDatabaseCache() {
        //  确定删除缓存的日期
        let date = Date(timeIntervalSinceNow: -kDBCacheDateTime)
        let df = DateFormatter()
        df.locale = Locale(identifier: "en")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dataString = df.string(from: date)
        
        //  执行清除缓存的代码
        let sql = "DELETE FROM T_Status WHERE createTime < '\(dataString)';"
        SQLiteManager.sharedManager.queue.inDatabase { (db) in
            if (db?.executeUpdate(sql, withArgumentsIn: nil))! {
                print("删除成功")
            } else {
                print("删除失败")
            }
        }
    }
    
    
    class func loadStatus(_ since_id: Int, max_id: Int, finished: @escaping (_ array: [[String: AnyObject]]?, _ error: NSError?) -> ()) {
        //  1. 检查本地是否有缓存数据
        loadCacheData(since_id, max_id: max_id) { (array) in
            
            if (array?.count ?? 0) > 0 {
                //  2. 有缓存，直接返回
                printLog("读取到 \(array!.count) 条数据")
                finished(array, nil)
            } else {
                //  3. 没有缓存，加载网络数据
                CFNetworkTools.sharedTools.loadStatus(since_id: since_id, max_id: max_id).subscribeNext({ (result) in
                    
                    let dict = result as! [String: AnyObject]
                    
                    guard let array = dict["statuses"] as? [[String: AnyObject]] else {
                        
                        finished(nil, NSError(domain: "", code: -1002, userInfo: ["errorMessage": "返回格式不正确"]))
                        return
                    }
                    
                    //  4. 加载完成后，将数据保存至‘数据库’
                    saveStatus(array)
                    //  5. 完成回调
                    finished(array, nil)
                    printLog("刷新到 \(array.count) 条数据")

                })
                
            }
            
        }

    }
    
    /// 加载缓存数据
    class func loadCacheData(_ since_id: Int, max_id: Int, finished: @escaping (_ array: [[String: AnyObject]]?) -> ()) {
        let userId = CFUserAccountVM.sharedUserAccount.userAccount!.uid!
        
        var sql = "SELECT statusId, status, userId FROM T_Status \n" +
            "WHERE userId = \(userId) \n"
        if since_id > 0 {
            sql += "AND statusId > \(since_id) \n"
        } else if max_id > 0 {
            sql += "AND statusId < \(max_id) \n"
        }
        sql += "ORDER BY statusId DESC LIMIT 20;"
        
        SQLiteManager.sharedManager.queue.inDatabase { (db) in
            guard let result = try? db!.executeQuery(sql) else {
                finished(nil)
                return
            }
            //  返回一个 字典的数组
            var array = [[String: AnyObject]]()
            while result.next() {
                let jsonString = result.string(forColumn: "status")
                let dict = try! JSONSerialization.jsonObject(with: (jsonString?.data(using: String.Encoding.utf8))!, options: JSONSerialization.ReadingOptions(rawValue: 0))
                
                array.append(dict as! [String : AnyObject])
            }
            
            //  通过回调返回
            finished(array)
        }
        
    }
    
    //  将数据保存到数据库中
    
    class func saveStatus(_ array: [[String: AnyObject]]) {
        /// 1. 字段中一定要有主键，主键不能自动增长（INSERT OR REPLACE sqlite3特有语法）
        let sql = "INSERT OR REPLACE INTO T_Status (statusId, status, userId) VALUES (?, ?, ?)"

        SQLiteManager.sharedManager.queue.inTransaction { (db, rollback) in
            //  判断用户是否登录
            assert(CFUserAccountVM.sharedUserAccount.userLogin, "用户必须登录")
            let userId = CFUserAccountVM.sharedUserAccount.userAccount!.uid!
            //  1. 遍历数组
            for dict in array {
                //  1. 微博代号
                let statusId = dict["id"] as! Int
                //  2. status 是字典对应的 json 字符串，序列化
                let json = try! JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions(rawValue: 0))
                let jsonString = NSString(data: json, encoding: String.Encoding.utf8.rawValue)!
                
                //  3. 插入数据
                if !(db?.executeUpdate(sql, withArgumentsIn: [statusId, jsonString, userId]))! {
                    rollback?.pointee = true
                    break
                }
            }
            
            print("保存了 \(array.count) 条结果")
            
        }
        
    }
    
}
 
