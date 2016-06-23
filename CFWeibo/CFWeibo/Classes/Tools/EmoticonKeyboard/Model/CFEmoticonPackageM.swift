//
//  CFEmoticonPackageM.swift
//  14. 表情键盘
//
//  Created by 成飞 on 16/4/21.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit

class CFEmoticonPackageM: NSObject {
     /// 目录名
    var id: String?
     /// 分组名
    var group_name_cn: String?
     /// 表情符号数组
    lazy var emoticons = [CFEmoticonM]()
    
    init(dict: [String: AnyObject]) {
        super.init()
        
        id = dict["id"] as? String
        group_name_cn = dict["group_name_cn"] as? String
        
        //  每隔 20 个按钮添加一个删除按钮
        var index = 0
        if let array = dict["emoticons"] as? [[String: String]] {
            //  创建 emotion 数组
            for dic in array {
                //  拼接 png 的路劲，将 id + "/" + png，后续再读取图片的时候直接使用包路径就可以了
                let emoticonM = CFEmoticonM(dict: dic)
                if emoticonM.type == "0" {
                    emoticonM.png = id! + "/" + emoticonM.png!
                }
                emoticons.append(emoticonM)
                
                index += 1
                if index % 20 == 0 {
                    emoticons.append(CFEmoticonM(isRemove: true))
                }
                
            }
        }
        appendBlankEmoticon()

    }
    /// 追加空白表情
    func appendBlankEmoticon() {
        let count = emoticons.count % 21
                
        if count == 0 && emoticons.count > 0 { return }
        for _ in count..<20 {
            emoticons.append(CFEmoticonM(isEmpty: true))
        }
        emoticons.append(CFEmoticonM(isRemove: true))

    }
    
    override var description: String {
        let keys = ["id", "group_name_cn", "emoticons"]
        return dictionaryWithValuesForKeys(keys).description
    }

}
