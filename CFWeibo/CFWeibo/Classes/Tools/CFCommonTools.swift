//
//  CFCommonTools.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/3.
//  Copyright © 2016年 成飞. All rights reserved.
//
/// 常用工具
import Foundation

//  MARK: - 通知常量定义
/// 切换根控制器通知
let CFSwitchRootVCNotification = NSNotification.Name(rawValue: "CFSwitchRootVCNotification")


//  MARK: - 输出日志
/// 输出日志
///
/// - parameter message:  日志消息
/// - parameter logError: 错误标记，默认false，如果是true，发布时仍然输出
/// - parameter file:     文件名
/// - parameter method:   方法名
/// - parameter line:     代码行数
func printLog<T> (_ message: T,
    logError: Bool = false,
    file: String = #file,
    method: String = #function,
    line: Int = #line)
{
    if logError {
        print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    } else {
        #if DEBUG
            print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
        #endif
    }
        
}
