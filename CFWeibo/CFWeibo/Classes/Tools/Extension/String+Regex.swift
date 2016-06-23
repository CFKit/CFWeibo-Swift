//
//  String+Regex.swift
//  18. 正则表达式
//
//  Created by 成飞 on 16/6/21.
//  Copyright © 2016年 成飞. All rights reserved.
//

import Foundation

extension String {
    //  从当前字符串中，提取超文本链接的 URL & 地址
    func href() -> (link: String, text: String)? {
        /**     匹配方案
         将要匹配的文字复制到 pattern
         将要查找的内容，使用 (.*?) 替换
         将要忽略的内容，使用  .*?  替换
         圆括号表示要获取的结果，从左至右依次递增匹配结果的索引
         
         */
        
        let pattern = "<a href=\"(.*?)\" rel=\".*?\">(.*?)</a>"
        
        //  定义正则表达式
        //  DotMatchesLineSeparators 能否让 . 匹配换行符 - 通常用在抓取网页数据
        let regex = try! NSRegularExpression(pattern: pattern, options: [NSRegularExpressionOptions.DotMatchesLineSeparators])
        
        //  使用正则表达式匹配字符串
        //  1. firstMatchInString 匹配第一个结果
        /**     NSTextCheckingResult
         numberOfRanges: Int 返回匹配的 range 个数
         rangeAtIndex(idx: Int) -> NSRange 返回索引对应的 NSRange
         */
        guard let result = regex.firstMatchInString(self, options: [], range: NSRange(location: 0, length: self.characters.count)) else {
            return nil
        }
        
        let link = (self as NSString).substringWithRange(result.rangeAtIndex(1))
        let text = (self as NSString).substringWithRange(result.rangeAtIndex(2))

        return (link, text)
    }
    
}