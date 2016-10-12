//
//  SQLiteManager.swift
//  23. FMDB测试
//
//  Created by 成飞 on 16/7/4.
//  Copyright © 2016年 成飞. All rights reserved.
//
//  默认数据库文件名，如果以db结尾，容易被发现
/// SQLite 公开的版本不支持加密
private let dbname = "my.db"

class SQLiteManager {
    static let sharedManager = SQLiteManager()
    //  能够保证线程安全
    let queue: FMDatabaseQueue
   
    //  在 '构造函数' 建立数据库队列
    fileprivate init() {
        let path = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last! as NSString).appendingPathComponent(dbname)
        print(path)
        queue = FMDatabaseQueue(path: path)
        createTable()
    }
    
    fileprivate func createTable() {
        //executeStatements - 执行很多sql
        //executeQuery - 执行查询
        //executeUpdate - 执行单挑 SQL 插入/更新/删除 除了 SELECT 都可以
        
        let path = Bundle.main.path(forResource: "weibo.sql", ofType: nil)!
        let sql = try! String(contentsOfFile: path)
        queue.inTransaction { (db, rollback) in
            if (db?.executeStatements(sql))! {
                print("成功")
            } else {
                print("失败")
            }
            

        }
        
        
    }
    
    
}
