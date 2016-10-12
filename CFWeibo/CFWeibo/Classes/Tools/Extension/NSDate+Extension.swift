//
//  NSDate+Extension.swift
//  17. 日期字符串
//
//  Created by 成飞 on 16/6/21.
//  Copyright © 2016年 成飞. All rights reserved.
//

import Foundation

extension Date {
    //  返回日期的描述字符串
    /*
     - 刚刚(1分钟内)
     - X分钟前(一小时内)
     - X小时前(当天)
     - 昨天 HH:mm(昨天)
     - MM-dd HH:mm(一年内)
     - yyyy-MM-dd HH:mm(更早)
     */
    var dateDescription: String {
        //  1. 日历类 -提供了非常丰富的日期转换函数
        let calendar = Calendar.current
        
        var fmtString = ""
        if calendar.isDateInToday(self) {
            //  今天
            let delta = Int(Date().timeIntervalSince(self))
            
            if delta < 60 {
                fmtString = "刚刚"
            } else if (delta < 3600) {
                fmtString = "\(delta / 60)分钟前"
            } else {
                fmtString = "\(delta / 3600)小时前"
            }
        } else if calendar.isDateInYesterday(self) {
            //  昨天
            fmtString = "昨天 HH:mm"
        } else {
            fmtString = "MM-dd"
            
            //  计算两个日期之间的差值，如果是年度差会计算一个完整年
            let componentsYear = (calendar as NSCalendar).components(.year, from: self, to: Date(), options: [])

            if componentsYear.year! > 0 {
                fmtString = "yyyy-" + fmtString
            }
        }
        
        let df = DateFormatter()
        df.locale = Locale(identifier: "en")
        df.dateFormat = fmtString
        
        return df.string(from: self)

        //  提取日期中指定‘单位 year/month/day...’的数字
//        print(calendar.component(.Year, fromDate: self))
        
    }
    
    /// 将新浪的日期格式字符串生成一个日期
    ///
    /// - parameter str: str
    ///
    /// - returns: date
    static func sinaDate(_ str: String) -> Date?{
        //  1. 转换日期
        let df = DateFormatter()
        //  以前版本的模拟器不需要指定，但是真机一定要，否则会出错
        df.locale = Locale(identifier: "en")
        df.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
        //  生成日期
        return df.date(from: str)
    }
}
