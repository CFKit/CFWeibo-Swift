//
//  CFEmoticonM.swift
//  14. 表情键盘
//
//  Created by 成飞 on 16/4/21.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit

/// 表情符号模型
class CFEmoticonM: NSObject {
     /// 表情文字(简体)
    var chs: String?
     /// 表情文字(繁体)
    var cht: String?
     /// gif 名字
    var gif: String?
     /// 表情图片
    var png: String?
    
    var imagePath: String {
        return type == "0" ?  Bundle.main.bundlePath + "/Emoticons.bundle/" + png! : ""
    }
    
     /// 图片类型 (0：png，1：emoji)
    var type: String?
    
     /// emoji 编码
    var code: String? {
        didSet {
            let scanner = Scanner(string: code!)
            var value: UInt32 = 0
            scanner.scanHexInt32(&value)
            emoji = String(Character(UnicodeScalar(value)!))
        }
    }
    
     /// emoji字符串
    var emoji: String?
     /// 删除按钮标记
    var isRemove = false
     /// 空白按钮标记
    var isEmpty = false
    
    /// 构造删除按钮
    init(isEmpty: Bool) {
        super.init()
        
        self.isEmpty = isEmpty
    }
    
    /// 构造删除按钮
    init(isRemove: Bool) {
        super.init()
        
        self.isRemove = isRemove
    }
    
    init(dict: [String: String]) {
        super.init()
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
    
    override var description: String {
        let keys = ["chs", "cht", "gif", "png", "type", "type", "code", "isEmpty", "isRemove"]
        return dictionaryWithValues(forKeys: keys).description
    }
}
