//
//  CFNetworkTools.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/2.
//  Copyright © 2016年 成飞. All rights reserved.
//
import UIKit
import AFNetworking
import ReactiveCocoa

//  Swift 中枚举的变化非常大，可以有构造函数，可以有静态函数，可以有函数，可以遵守协议
enum RequestMethod: String {
    case GET = "GET"
    case POST = "POST"
}

///  网络工具类
class CFNetworkTools: AFHTTPSessionManager {
    
    //  MARK: - App 信息
    private let clientId = "3020759535"
    private let appSecret = "c7364dc8755f751800d50a2ae4dc1a0a"
    let redirectUri = "http://www.hao123.com"
    
    //  单例
    static let sharedTools: CFNetworkTools = {
        var instance = CFNetworkTools(baseURL: nil)
        instance.responseSerializer.acceptableContentTypes?.insert("text/plain")

        return instance
    } ()
    
    //  MARK: - 微博数据
    /// 发布微博
    ///
    /// - parameter status: 微博文本，不能超过 140 个字，需要百分号转义
    /// - parameter image: 如果有就上传
    ///
    /// - see: [http://open.weibo.com/wiki/2/statuses/update](http://open.weibo.com/wiki/2/statuses/update)
    /// - see: [http://open.weibo.com/wiki/2/statuses/upload](http://open.weibo.com/wiki/2/statuses/upload)
    ///
    /// - returns: RACSignal
    func sendStatus(status: String, image: UIImage?) -> RACSignal {
        
        let params = ["status": status]
        
        //  如果没有图片，就是文本微博
        if image == nil {
            return request(RequestMethod.POST, URLString: "https://api.weibo.com/2/statuses/update.json", parameters: params)
        } else {
            return upload("https://upload.api.weibo.com/2/statuses/upload.json", parameters: params, image: image!)
        }
        
    }
    
    /// 加载微博数据
    /// - parameter since_id:   返回 id 比 since_id 大的微博
    /// - parameter max_id:     返回 id 小于或等于 max_id 的微博
    /// - see:[http://open.weibo.com/wiki/2/statuses/home_timeline](http://open.weibo.com/wiki/2/statuses/home_timeline)
    func loadStatus(since_id since_id: Int, max_id: Int) -> RACSignal {
        let urlString = "https://api.weibo.com/2/statuses/home_timeline.json"
        var params = [String: AnyObject]()
        if since_id > 0 {
            params["since_id"] = since_id
        } else if max_id > 0 {
            //  TODO: max_id 错误
            params["max_id"] =  max_id - 1
        }
        
        return request(.GET, URLString: urlString, parameters: params)
    }

    
    //  MARK: - OAuth
    /// OAuth 授权 url
    /// - see:[http://open.weibo.com/wiki/Oauth2/authorize](http://open.weibo.com/wiki/Oauth2/authorize)
    var oauthUrl: NSURL {
        let urlString = "https://api.weibo.com/oauth2/authorize?client_id=\(clientId)&redirect_uri=\(redirectUri)"
        //  https://api.weibo.com/oauth2/authorize?client_id=3020759535&redirect_uri=http://www.hao123.com
        return NSURL(string: urlString)!
    }
    
    
    /// 获取 AccessToken
    ///
    /// - see: [http://open.weibo.com/wiki/OAuth2/access_token](http://open.weibo.com/wiki/OAuth2/access_token )
    /// - parameter code: 请求码/授权码
    func loadAccessToken(code: String) -> RACSignal {
        let urlString = "https://api.weibo.com/oauth2/access_token"
        
        
        let params = ["client_id": clientId,
            "client_secret": appSecret,
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectUri]
        
//  测试返回数据的代码 -> 测试将结果转换成字符串（不让 json 反序列化）
//  响应数据格式是二进制的
//  responseSerializer = AFHTTPResponseSerializer()
//  POST(urlString, parameters: params, progress: nil, success: { (_, result) -> Void in
//      printLog(result)
//  转成字符串 NSString
//            let string = NSString(data: result as! NSData, encoding: NSUTF8StringEncoding)
//  JSON 字符串中，如果数字没有引号，反序列化的结果是 NSNumber， KVC 无法给 String 类型的属性设置数值
//            printLog(string)
//            
//            
//            }, failure: nil)
//        return RACSignal.empty()
        return request(.POST, URLString: urlString, parameters: params, needToken: false);
    }
    
    /// 加载用户请求信息
    ///
    /// - parameter uid:          uid
    /// - see: [http://open.weibo.com/wiki/2/users/show](http://open.weibo.com/wiki/2/users/show)
    /// - returns: RAC Signal
    func loadUserInfo(uid: String) -> RACSignal {
        let urlString = "https://api.weibo.com/2/users/show.json"
        let params = ["uid": uid];
        
        return request(.GET, URLString: urlString, parameters: params);
    }
    
    
    //  MARK: - 私有方法，封装AFN
    /// 在指定参数中追加 accessToken
    ///
    /// - parameter parameters: parameters 地址
    ///
    /// - returns: 是否成功，如果token失效的时候返回false
    private func appendToken(inout parameters: [String: AnyObject]?) -> Bool {
        //  判断 token 是否存在，guard 刚好是和 if let 相反
        guard let token = CFUserAccountVM.sharedUserAccount.accessToken else {
            return false
        }
        
        //  判断是否传递了参数字典
        if parameters == nil {
            parameters = [String: AnyObject]()
        }
        //  后续 token 都是有值的
        parameters!["access_token"] = token
        
        return true
    }
    
    /// 网络请求(对 AFN 的 get/post 进行了封装)
    ///
    /// - parameter method:     method
    /// - parameter URLString:  URLString
    /// - parameter parameters: 参数字典
    /// - parameter needToken:  是否包含token，默认 true
    /// - returns: RAC Signal
    private func request(method: RequestMethod, URLString: String, parameters: [String: AnyObject]?, needToken: Bool = true) -> RACSignal {
        return RACSignal.createSignal({ (subscriber) -> RACDisposable! in
            var dict = parameters
            
            //  如果 token 失效，直接返回错误
            if needToken && !self.appendToken(&dict) {
                subscriber.sendError(NSError(domain: "com.cf.error", code: -1001, userInfo: ["errorMessage": "token 为空"]))
                return nil
            }

            //  1. 成功的回调闭包
            let successCallBack = { (task: NSURLSessionDataTask, result: AnyObject?) -> Void in
                //  发送给订阅者
                subscriber.sendNext(result)
                subscriber.sendCompleted()
            }
            let failureCallBack = { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                //  即使应用程序已经发布，在网络访问中，如果出现错误，仍然要输出日志，属于严重级别的错误
                printLog(error, logError: true)
                subscriber.sendError(error)
                subscriber.sendCompleted()
            }
            let progressCallBack = { (progress: NSProgress) -> Void in
                
            }
            
            if method == .GET {
                self.GET(URLString, parameters: dict, progress:progressCallBack, success: successCallBack, failure: failureCallBack)
                
            } else {
                self.POST(URLString, parameters: dict, progress:progressCallBack, success: successCallBack, failure: failureCallBack)
            }
            
            return nil
        })
        
    }
    
    /// 上传文件
    ///
    /// - parameter URLString:  上传地址
    /// - parameter parameters: 参数字典
    /// - parameter image:      image
    ///
    /// - returns: RACSignal
    private func upload( URLString: String, parameters: [String: AnyObject]?, image: UIImage) -> RACSignal {
        //  RAC 闭包返回值是对信号销毁时需要做的内存销毁工作，同样是一个 block，AFN 可以直接返回 nil
        return RACSignal.createSignal() { (subscriber) -> RACDisposable! in
            var dict = parameters
            
            //  如果 token 失效，直接返回错误
            if !self.appendToken(&dict) {
                subscriber.sendError(NSError(domain: "com.cf.error", code: -1001, userInfo: ["errorMessage": "token 为空"]))
                return nil
            }

            //  调用 AFN 上传文件方法
            self.POST(URLString, parameters: dict, constructingBodyWithBlock: { (formData) in
                let data = UIImagePNGRepresentation(image)!
                
                //  处理图片文件
                //appendPartWithFileData(data: NSData, name: String, fileName: String, mimeType: String)
                //  formData 是遵守协议的对象，AFN 内部提供的，使用的时候，只需要按照协议方法传递参数即可
                /*
                 1. 要上传图片的二进制数据
                 2. 服务器的字段名，开发的时候使用，询问后台
                 3. 保存在服务器的文件名，很多后台允许随便写
                 4. 客户端告诉服务器上传文件的类型，格式：大类/小类 image/jpg、iamge/gif。如果不想告诉服务器类型，可以使用 application/octet-strem
                 */
                formData.appendPartWithFileData(data, name: "pic", fileName: "myImage", mimeType: "application/octet-strem")
                
                }, progress: { (progress) in
                    print(progress);
                }, success: { (_, result) in
                    //  发送给订阅者
                    subscriber.sendNext(result)
                    subscriber.sendCompleted()

                }, failure: { (_, error) in
                    //  即使应用程序已经发布，在网络访问中，如果出现错误，仍然要输出日志，属于严重级别的错误
                    printLog(error, logError: true)
                    subscriber.sendError(error)
                    subscriber.sendCompleted()

            })
            return nil
        }
    }

}
