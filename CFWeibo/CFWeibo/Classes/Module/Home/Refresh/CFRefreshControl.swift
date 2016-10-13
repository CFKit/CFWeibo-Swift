//
//  CFRefreshControl.swift
//  CFWeibo
//
//  Created by 成飞 on 16/3/31.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
import SnapKit
/// 向下拖拽的偏移量
private let kRefreshControlMaxOfset: CGFloat = -60

/// 刷新控件，负责和控制器交互
class CFRefreshControl: UIRefreshControl {
    
    
    override func endRefreshing() {
        super.endRefreshing()
        
        refreshView.stopLoadingAnimation()
    }
    
    //  MARK: - KVO 监听
    //  翻转标记
    //  private var rotateFlag = false
    //  监听对象的 key value 一旦变化，就会调用此方法
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        /*
            越向下 y 越小，小到一定程度自动进入刷新状态
         */
        
        if frame.origin.y > 0 { return }
        //  判断是否正在上刷新
        if  isRefreshing {
//            refreshView.startLoadingAnimation()
            return
        }
        
        if !refreshView.rotateFlag && frame.origin.y < kRefreshControlMaxOfset {
            refreshView.rotateFlag = true
        } else if refreshView.rotateFlag && frame.origin.y >= kRefreshControlMaxOfset {
            refreshView.rotateFlag = false
        }
    }
    
    //  MARK: - 构造函数
    override init() {
        super.init()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        setupUI()
    }
    
    deinit {
        //  销毁监听
        self.removeObserver(self, forKeyPath: "frame")
    }
    
    fileprivate func setupUI() {
        //  KVO  self 监听 self.frame
        self.addObserver(self, forKeyPath: "frame", options: [], context: nil)
        
        
        tintColor = UIColor.clear
        addSubview(refreshView)
        
        //  自动布局，从 xib 加载的视图会保留 xib 中指定的大小
        refreshView.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.size.equalTo(refreshView.bounds.size)
        }
    }
    
    func addRefreshing(_ target: AnyObject, selector: Selector) {
        self.refreshingTarget = target
        self.refreshingSelector = selector
    }
    
    
    //  MARK: - 懒加载控件
    fileprivate lazy var refreshView = CFRefreshView.refreshView()
    
    var refreshingSelector: Selector?
    var refreshingTarget: AnyObject?
    
}

/// 刷新视图，负责显示内容和动画
class CFRefreshView: UIView {
    /// 旋转标记
    fileprivate var rotateFlag = false {
        didSet {
            rotatePulldownIconAnimation()
        }
    }

    /// 加载图标
    @IBOutlet weak var loadingIcon: UIImageView!
    /// 下拉显示的 view
    @IBOutlet weak var pulldownView: UIView!
    /// 下拉提示图标
    @IBOutlet weak var pulldownIcon: UIImageView!
    //  从 xib 加载 refreshView
    class func refreshView() -> CFRefreshView {
        return Bundle.main.loadNibNamed("CFRefreshView", owner: nil, options: nil)!.last! as! CFRefreshView
    }
    
    fileprivate func rotatePulldownIconAnimation() {
       
        var angle = CGFloat(M_PI)
        angle += rotateFlag ? -0.001 : 0.001
        
        //  在 iOS 的闭包动画中，默认是顺时针旋转，就近原则
        UIView.animate(withDuration: 0.5, animations: {
            self.pulldownIcon.transform = self.pulldownIcon.transform.rotated(by: angle)
        }) 
    }
    
    fileprivate func startLoadingAnimation() {
        //  通过 key 能够拿到涂层上的动画
        let loadingKey = "loadingKey"
        if loadingIcon.layer.animation(forKey: loadingKey) != nil {
            return
        }
        
        pulldownView.isHidden = true
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.toValue = 2 * M_PI
        anim.repeatCount = MAXFLOAT
        anim.duration = 1
        loadingIcon.layer.add(anim, forKey: loadingKey)
    }
    
    fileprivate func stopLoadingAnimation() {
        pulldownView.isHidden = false
        loadingIcon.layer.removeAllAnimations()
    }
}


