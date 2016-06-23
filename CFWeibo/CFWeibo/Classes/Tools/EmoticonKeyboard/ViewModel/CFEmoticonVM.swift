//
//  CFEmoticonVM.swift
//  14. 表情键盘
//
//  Created by 成飞 on 16/4/21.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
/// 表情视图模型 -> 加载表情数据 从 EMoticon.bundle 中读取 emoticons.plist，遍历 packages 数组，创建 EMoticonPackage 数组。 EMoticonPackage 的明细内容从 id 对应的目录加载 info.plist 完成字典转模型
/*
 在 Swift 中，一个对象可以不继承 NSObject
 - 继承 NSObject 可以使用 KVC 方法给属性设置数值 => 如果是模型对象就集成
 - 如果对象，没有属性，或者不依赖 KVC，可以建立一个没有父类的对象，对象的量级比较轻，内存消耗小
 */
class CFEmoticonVM {
    
     /// 单例
    static let sharedEmoticonVM = CFEmoticonVM()
    
    //  能保证外界只能通过单例属性访问对象，不能直接实例化
    private init() {
        //  加载表情包
        loadPackages()
    }
    
     /// 表情包的数组
    lazy var packages = [CFEmoticonPackageM]()
    
    /// 根据给定的字符串，生成带表情符号的属性字符串
    func emoticonText(str: String, font: UIFont) -> NSAttributedString {
        //  2. 使用正则表达式，拆解字符串 [] 在正则表达式中是保留字，如果 pattern 中要使用，需要转移
        let pattern = "\\[.*?\\]"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        //  matchesInString 查找所有的匹配项
        let results = regex.matchesInString(str, options: [], range: NSRange(location: 0, length: (str as NSString).length))
        
        
        
        //  准备属性字符串
        let strM = NSMutableAttributedString(string: str)
        
        //  获得数组数量
        var count = results.count
        //  根据数量 ‘倒序’ 遍历数组内容
        while count > 0 {
            count = count - 1
            let range = results[count].rangeAtIndex(0)
            
            //  根据 range 获取到对应的 chs 字符串
            let chs = (str as NSString).substringWithRange(range)
            
            if let emoticon = emoticon(chs) {
                let imageText = CFEmoticonAttachment.emoticonAttributeText(emoticon, font: font)
                //  替换 strM 中对应的属性文本
                strM.replaceCharactersInRange(range, withAttributedString: imageText)
                
            }
            
        }
        
        return strM
    }
    
    func emoticon(str: String) -> CFEmoticonM? {
        
        //  通过视图模型的单例 -> packages 所有表情包数组 -> emoticons 'chs == str'
        //  遍历 packages 数组
        var emoticon: CFEmoticonM?
        for p in packages {
//              从 packages 数组中 '过滤' 出指定字符串的表情
//            emoticon = p.emoticons.filter({ (em) -> Bool in return em.chs == str }).last
            emoticon = p.emoticons.filter() { $0.chs == str }.last
            
            //  如果找到 emoticon 直接退出
            if (emoticon != nil) { break }
            
        }
        
        return emoticon
    }

    
    /// 添加最近的表情
    ///
    /// - parameter indexPath: indexPath
    func favorite(emoticon: CFEmoticonM) {

        //  1. 获取表情符号

        if emoticon.isRemove {
            return
        }
        
        //  2. 将表情符号添加到第 0 组 第一个。
        //  判断是否已经存在表情
        if !packages[0].emoticons.contains(emoticon) {
            packages[0].emoticons.insert(emoticon, atIndex: 0)
        } else {
            let index = packages[0].emoticons.indexOf(emoticon)
            packages[0].emoticons.removeAtIndex(index!)
            packages[0].emoticons.insert(emoticon, atIndex: 0)
        }
        
        //  删除多余表情。 倒数第二个
        if packages[0].emoticons.count > 21 {
            packages[0].emoticons.removeAtIndex(20)
        }
        
//        printLog(packages[0].emoticons as NSArray)
//        printLog(packages[0].emoticons.count)
        
    }
    
    /// 根据 indexPath 返回对应的表情模型
    func emoticon(indexPath: NSIndexPath) -> CFEmoticonM {
        
        let page = indexPath.row / (maxRow * maxLine)
        let pageCount = indexPath.row % (maxRow * maxLine)
        
        let index = pageCount % maxRow * maxLine + pageCount / maxRow + page * maxLine * maxRow
        
        return packages[indexPath.section].emoticons[index]
    }
    
    //  MARK: - 私有函数
    /// 加载表情包
    private func loadPackages() {
        
        //  增加最近分组
        packages.append(CFEmoticonPackageM(dict: ["group_name_cn": "最近"]))
        
        //  1. 读取 emoticons.plist 
        let path = NSBundle.mainBundle().pathForResource("emoticons.plist", ofType: nil, inDirectory: "Emoticons.bundle")
        //  2. 读取字典
        let rootDict = NSDictionary(contentsOfFile: path!)
        //  3. 获取 package 数组
        let array = rootDict!["packages"] as! [[String: AnyObject]]
        //  4. 遍历数组，创建模型
        for dict in array {
            //  1> 获取 字典中的 id
            let id = dict["id"] as! String
            //  2> 拼接表情包路劲
            let emPath = NSBundle.mainBundle().pathForResource("info.plist", ofType: nil, inDirectory: "Emoticons.bundle/" + id)
            //  3> 加载 info.plist 字典
            let infoDict = NSDictionary(contentsOfFile: emPath!) as! [String: AnyObject]
            //  4> 字典转模型
            packages.append(CFEmoticonPackageM(dict: infoDict))
        }
        
        print(packages)
        
    }
}