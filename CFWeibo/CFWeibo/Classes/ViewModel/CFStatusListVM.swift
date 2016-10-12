//
//  CFStatusListVM.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/16.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
import ReactiveCocoa
import SDWebImage

/// 微博列表的视图模型 - 分立网络方法
class CFStatusListVM: NSObject {

    /// 微博数据数组
    lazy var statusList: [CFStatusVM] = [CFStatusVM]()//  目前只能写 AnyObject 不然出错
    
    /// 加载数据
    ///
    /// - parameter isPullupRefresh: 是否上拉刷新标记
    ///
    /// - returns: RACSignal
    func loadStatus(_ isPullupRefresh: Bool) -> RACSignal {
        
        //  1. 初始刷新: status 数组没有内容
        //  2. 下拉刷新
        var since_id = statusList.first?.status.id ?? 0
        var max_id = 0
        //  3. 上拉刷新
        if isPullupRefresh {
            since_id = 0
            max_id = statusList.last?.status.id ?? 0
        }
        
        //  RACSignal 在订阅的时候，会对 self 进行强引用，sendCompleted 说明信号完成，会释放对 self 的强引用
        return RACSignal.createSignal({ [weak self] (scriber) -> RACDisposable! in
            CFStatusDAL.loadStatus(since_id, max_id: max_id, finished: { (array, error) in
                
                if (array?.count ?? 0) > 0 {
                    //  2. 字典转模型(定义一个临时数组)
                    var arrayM = [CFStatusVM]()
                    for dict in array! {
                        arrayM.append(CFStatusVM(status: CFStatus(dict: dict)))
                    }

                    self?.cacheWebImage(arrayM, finished: { 
                        if max_id > 0 { //  上拉刷新
                            self?.statusList += arrayM
                        } else { // 默认初始刷新，下拉刷新
                            self?.statusList = arrayM + self!.statusList
                        }

                        //  如果是下拉刷新，提示用户刷新
                        if since_id > 0 {
                            //  RAC 是 OC 的。通知订阅者，下拉刷新的数据
                            scriber?.sendNext(arrayM.count)
                        }
                        //printLog(self?.statusList)
                        scriber?.sendCompleted()

                    })
                    
                } else if error != nil {
                    scriber?.sendError(error)
                }
            })
            
            return nil
        })

    }
    
    fileprivate func cacheWebImage(_ statusVMList: [CFStatusVM], finished: @escaping () -> Void) {
        
        //  1. 定义一个调度组
        let group = DispatchGroup()
        var dataLength = 0
        
        //  遍历视图模型数组
        for statusVM in statusVMList {
            let count = statusVM.bmiddleURLs?.count ?? 0
            
            if count != 1 { continue }
            
            //  2. 入组（紧贴block。且必须配对出现）
            group.enter()
            //  使用 SDWebImage 下载图片
            SDWebImageManager.shared().downloadImage(with: statusVM.bmiddleURLs![0] as URL!, options: [], progress: nil, completed: { (image, _, _, _, _) in
                
                //  图片缓存完成
                if image != nil {
                    let data  = UIImagePNGRepresentation(image!)
                    dataLength += data?.count ?? 0
                }
                
                //  3. 出组(block 最后一句)
                group.leave()
            })
            
        }
        //  4. 调度组监听
        group.notify(queue: DispatchQueue.main) { 
            printLog("缓存图像完成 \(dataLength / 1024) K")
            
            //  执行闭包
            finished()
        }
        
    }

}
