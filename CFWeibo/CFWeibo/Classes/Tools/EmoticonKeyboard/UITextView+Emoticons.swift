//
//  UITextView+Emoticons.swift
//  14. 表情键盘
//
//  Created by 成飞 on 16/6/6.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit

extension UITextView {
    
    //  文本长度
    var emoticonTextLength: Int {
        let attrText = attributedText
        var length = 0
        attrText.enumerateAttributesInRange(
            NSRange(location: 0, length: attrText.length),
            options: []) { (dict, range, _) in
                if let attachment = dict["NSAttachment"] as? CFEmoticonAttachment {
                    length += (attachment.chs?.characters.count)! - 1
                } else {
                    let str = (attrText.string as NSString).substringWithRange(range)
                    length += str.characters.count
                }
        }
        return length
    }

    /// 计算型属性
    var emoticonText: String {
        let attrText = attributedText
        var strM = String()
        attrText.enumerateAttributesInRange(
            NSRange(location: 0, length: attrText.length),
            options: []) { (dict, range, _) in
                if let attachment = dict["NSAttachment"] as? CFEmoticonAttachment {
                    strM += attachment.chs!
                } else {
                    let str = (attrText.string as NSString).substringWithRange(range)
                    strM += str
                }
        }
        
        return strM
    }
    
    /// 插入表情符号
    ///
    /// - parameter emoticon: 表情符号模型
    func insertEmoticon(emoticon: CFEmoticonM) {

        //  1. 删除按钮
        if emoticon.isRemove == true {
            deleteBackward()
            return
        }
        //  2. emjo
        if emoticon.type == "1" {
            replaceRange(selectedTextRange!, withText: emoticon.emoji!)
            return
        }
        //  3. 表情图片
        let imageText = CFEmoticonAttachment.emoticonAttributeText(emoticon, font: font!)
        
        let mStr = NSMutableAttributedString(attributedString: attributedText)
        mStr.replaceCharactersInRange(selectedRange, withAttributedString: imageText)
        
        //  记录光标当前位置
        let range = selectedRange
        attributedText = mStr
        //  恢复光标位置
        selectedRange = NSMakeRange(range.location + 1, 0)
        
        //  执行代理方法 - !表示代理一定要实现这个方法
        delegate?.textViewDidChange!(self)
    }
    
    
}
