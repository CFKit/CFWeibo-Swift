//
//  CFQRCodeVC.swift
//  CFWeibo
//
//  Created by 成飞 on 16/6/22.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
import AVFoundation
import SVProgressHUD

class CFQRCodeVC: UIViewController {

    @IBOutlet weak var tabBar: UITabBar!
    /// 冲击波图像
    @IBOutlet weak var scanImageView: UIImageView!
    
    /// 冲击波顶部约束
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    /// 容器视图高度
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    /// 容器视图宽度
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.selectedItem = tabBar.items![0]
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        barAnimation()
        //  开始扫描
        scan()
        
    }

    //  MARK: - 二维码扫描
    //  1. 拍摄会话 - 扫描的桥梁
    lazy var session: AVCaptureSession = {
        
        return AVCaptureSession()
    }()
    
    //  2. 输入设备 - 摄像头
    lazy var videoInput: AVCaptureDeviceInput = {
        //  拿到摄像头设备
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let input = try! AVCaptureDeviceInput(device: device)
        
        return input
    }()

    //  3. 输出数据
    lazy var dataOutput: AVCaptureMetadataOutput = {
        return AVCaptureMetadataOutput()
    } ()
    
    //  4. 预览视图
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        //  必须制定一个session
        let layer = AVCaptureVideoPreviewLayer(session: self.session)
        layer.frame = self.view.bounds
        
        return layer
    } ()
    
    //  5. 绘图图层
    lazy var drawLayer: CALayer = {
        let layer = CALayer()
        layer.frame = self.view.bounds
        
        return layer
    } ()
}

//  MARK: - 触发事件
extension CFQRCodeVC {
    
    //  开始扫描
    private func scan() {
        //  1. 判断会话能否添加输入设备
        if !session.canAddInput(videoInput) {
            SVProgressHUD.showInfoWithStatus("无法添加输入设备")
            return
        }
        //  2. 判断会话能否添加输出设备
        if !session.canAddOutput(dataOutput) {
            SVProgressHUD.showInfoWithStatus("无法添加输出设备")
            return
        }
        //  6. 添加预览图层
        view.layer.insertSublayer(drawLayer, atIndex: 0)
        view.layer.insertSublayer(previewLayer, atIndex: 0)
        
        //  3. 需要将设备添加到会话中，才能或得 - 输出数据支持的格式
        session.addInput(videoInput)
        session.addOutput(dataOutput)
        
        //  4. 设置输出识别的格式 & 代理
        dataOutput.metadataObjectTypes = dataOutput.availableMetadataObjectTypes
        dataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        
        //  5. 启动会话
        session.startRunning()
    }
    
    
    //  关闭界面
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //  查看相册
    @IBAction func lookPhotoAlbum(sender: AnyObject) {
        
    }
    
}

//  MARK: - 代理方法
extension CFQRCodeVC: UITabBarDelegate, AVCaptureMetadataOutputObjectsDelegate {
    //  MARK: -- AVCaptureMetadataOutputObjectsDelegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        clearDrawLayer()
        for codeObject in metadataObjects {
            if let obj = codeObject as? AVMetadataMachineReadableCodeObject {

                let object = previewLayer.transformedMetadataObjectForMetadataObject(obj) as! AVMetadataMachineReadableCodeObject
                drawCorners(object)
                
                SVProgressHUD.showInfoWithStatus(object.stringValue)
            }
        }
        
    }
    
    //  MARK: -- UITabBarDelegate
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        
        UIView.animateWithDuration(1) {
            self.heightConstraint.constant = (item.tag == 1 ? 0.5 : 1) * self.widthConstraint.constant
        }
        
        //  核心动画中，是将动画添加到图层 - 停止一下动画
        self.scanImageView.layer.removeAllAnimations()
        //  再次启动动画
        barAnimation()
        
    }
    
    
}

//  MARK: - 辅助方法
extension CFQRCodeVC {
    
    /// 清除绘图图层子视图
    private func clearDrawLayer() {
        if drawLayer.sublayers == nil {
            return
        }
        for layer in drawLayer.sublayers! {
            layer.removeFromSuperlayer()
        }
    }
    
    /// 绘制边线
    private func drawCorners(codeObject: AVMetadataMachineReadableCodeObject) {
        //  创建 'shape' layer 专门用来画图的
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.orangeColor().CGColor
        layer.lineWidth = 1.0
        layer.fillColor = UIColor.clearColor().CGColor
        
        //  设置路径
        //  corners 中保存的是 CFDictionary objects 数组
        layer.path = createPath(codeObject.corners).CGPath
         
        drawLayer.addSublayer(layer)
        
    }
    
    private func createPath(points: NSArray) -> UIBezierPath {
        let path = UIBezierPath()
        var point = CGPoint()
        
        var index = 0
        //  1. 移动到第一个点
        CGPointMakeWithDictionaryRepresentation((points[index] as! CFDictionaryRef), &point)
        index += 1
        path.moveToPoint(point)
        
        //  2. 循环遍历剩下的点
        while index < points.count {
            CGPointMakeWithDictionaryRepresentation((points[index] as! CFDictionaryRef), &point)
            path.addLineToPoint(point)
            index += 1
        }
        //  3. 从起始点到结束点画一条线
        path.closePath()
        
        return path
    }
    
    
    //  冲击波动画
    private func barAnimation() {
    
        topConstraint.constant = -heightConstraint.constant
        //  强制更新布局
        view.layoutIfNeeded()
        
        UIView.animateWithDuration(2.0) {
            //  设置动画重复次数
            UIView.setAnimationRepeatCount(MAXFLOAT)
            self.topConstraint.constant = self.heightConstraint.constant
            self.view.layoutIfNeeded()
        }
        
    }
}