//
//  CFStatusVM.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/18.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


/// 微博视图模型，供界面显示只用
class CFStatusVM: NSObject {
    /// 微博对象
    var status: CFStatus
    
    /// 当前模型对应的行高
    var statusCellHeight: CGFloat = 0
    
    var statusCellIdentifier: String {
        return status.retweeted_status != nil ? kForwardStatusCellIdentifier : kOriginalityStatusIdentifier;
    }
    
    /// 被转发的原创微博文字
    var forwardText: String? {
        let username = status.retweeted_status?.user?.name ?? ""
        let text = status.retweeted_status?.text ?? ""

        return "@\(username):\(text)"
    }

    /// 用户头像 URL
    var userIconURL: URL? {
        return URL(string: status.user?.profile_image_url ?? "")
    }
    
    /// 认证类型
    // 计算型属性，写等号时为存储性属性，
    var userVipImage: UIImage? {
//        print(status.user?.verified)
        switch(status.user?.verified ?? -1) {
        case 0: return UIImage(named: "avatar_vip")
        case 2, 3, 5: return UIImage(named: "avatar_enterprise_vip")
        case 220: return UIImage(named: "avatar_grassroot")
        default: return nil
        }
    }
    
    //  会员等级 图片
    var levelImage: UIImage? {
        if status.user?.mbrank > 0 && status.user?.mbrank < 7 {
            return UIImage(named: "common_icon_membership_level\(status.user!.mbrank)")
        }
        return nil
    }
    
    /// 配图缩略图 URL 数组(如果原创微博有图，在 thumbnaiURLs数组中记录)
    var thumbnailURLs: [URL]?
    /// 中等图片 URL 数组
    var bmiddleURLs: [URL]? {
        //  1. 判断 thumbnailURLs 是否为 nil
        guard let urls = thumbnailURLs else {
            return nil
        }
        //  2. 顺序替换每一个 url 字符串中的单词
        var array = [URL]()
        for url in urls {
            let urlString = url.absoluteString.replacingOccurrences(of: "/thumbnail/", with: "/bmiddle/")
            array.append(URL(string: urlString)!)
        }
        return array;
    }
    /// 原始图片数组
    var originalURLs: [URL]? {
        //  1. 判断 thumbnailURLs 是否为 nil
        guard let urls = thumbnailURLs else {
            return nil
        }
        //  2. 顺序替换每一个 url 字符串中的单词
        var array = [URL]()
        for url in urls {
            let urlString = url.absoluteString.replacingOccurrences(of: "/thumbnail/", with: "/large/")
            array.append(URL(string: urlString)!)
        }
        return array
    }
    
    init(status: CFStatus) {
        self.status = status
        
        //  如果是转发微博，取 retweeted_status 的 pic_urls
        if let urls = status.retweeted_status?.pic_urls ?? status.pic_urls {
            thumbnailURLs = [URL]()
            for dict in urls {
                //  第一个！ 确保 key 一定在字典存在。第二个！ 确保 url 一定能创建出 URL。通常由后台返回的 URL 是添加过百分号转义的
                thumbnailURLs?.append(URL(string: dict["thumbnail_pic"]!)!)
            }
        }
        
        super.init()
    }

}

extension CFStatusVM {
    override var description: String {
        let keys = ["status", "thumbnailURLs", "bmiddleURLs", "originalURLs"]
        return dictionaryWithValues(forKeys: keys).description
    }
}
