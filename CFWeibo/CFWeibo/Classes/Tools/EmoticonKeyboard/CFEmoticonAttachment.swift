//
//  CFEmoticonAttachment.swift
//  14. 表情键盘
//
//  Created by 成飞 on 16/6/6.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit

class CFEmoticonAttachment: NSTextAttachment {
     /// 表情文字
    var chs: String?
    
    
    init(chs: String?) {
        self.chs = chs
        
        super.init(data: nil, ofType: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    class func emoticonAttributeText(_ emoticon: CFEmoticonM, font: UIFont) -> NSAttributedString {
        let attachment = CFEmoticonAttachment(chs: emoticon.chs)
        
        attachment.image = UIImage(contentsOfFile: emoticon.imagePath)
        //  指定图片高度asdf
        let height = font.lineHeight
        //  bounds 的 x/y 就是 scrollView 的 contentOffset 改变控件的位置
        attachment.bounds = CGRect(x: 0, y: -4, width: height, height: height)
        //  创建图片属性字符串
        let imageText = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
        //  添加字体
        imageText.addAttribute(NSFontAttributeName, value: font, range: NSRange(location: 0, length: 1))
        return imageText
    }
}
