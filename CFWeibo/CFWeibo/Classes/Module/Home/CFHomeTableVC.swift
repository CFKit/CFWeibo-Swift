//
//  CFHomeTableVC.swift
//  CFWeibo
//
//  Created by 成飞 on 16/2/29.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
import SVProgressHUD


class CFHomeTableVC: CFBaseTableVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !CFUserAccountVM.sharedUserAccount.userLogin {
            visitorView?.setupInfo("关注一些人，回这里看看有什么惊喜", imageName: nil)
            return
        }
        
        preparePhotoBrowserModal()
        prepareTableView()
        prepareNavigation()
        loadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //  MARK: - 懒加载控件
    /// Modal 动画提供者
    fileprivate lazy var photoBrowserAnimator = CFPhotoBrowserAnimator()
    
    /// 微博列表数据模型
    fileprivate lazy var statusListVM = CFStatusListVM()

    fileprivate lazy var pulldownMessageLabel: UILabel = {
     
        let label = UILabel(title: nil, color: UIColor.white, fontSize: 16)
        label.backgroundColor = UIColor.orange
        label.textAlignment = NSTextAlignment.center
        
        self.navigationController?.navigationBar.insertSubview(label, at: 0)

        return label
    }()
    
    /// 上拉刷新视图
    fileprivate lazy var pullupView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        indicator.color = UIColor.darkGray

        return indicator
    } ()
}

//  MARK: - 数据处理
extension CFHomeTableVC {
    
    @objc fileprivate func qrCodeShow() {
    

        self.present(UIStoryboard.initialViewController("QRCode"), animated: true, completion: nil)
    }
    
    /// 加载数据
    func loadData() {
        //  只会播放动画，不会加载数据
        statusListVM.loadStatus(pullupView.isAnimating).subscribeNext({ (result) in
            self.showPulldownMessage((result as! NSNumber).intValue)
            }, error: { (error) in
                printLog(error)
                self.endLoadingData()
                SVProgressHUD.showInfo(withStatus: "您的网络不给力")
        }) {
            //  刷新表格
            self.tableView.reloadData()
            self.endLoadingData()
        }
    }
    
    fileprivate func showPulldownMessage(_ count: Int) {
        let title = count == 0 ? "没有新微博" : "刷新到 \(count) 条微博"
        var rect = CGRect(x: 0, y: 44, width: kScreenWidth, height: 0)
        
        pulldownMessageLabel.frame = rect
        pulldownMessageLabel.text = title
        
        UIView.animate(withDuration: 0.5, animations: {
            rect.size.height = 40
            self.pulldownMessageLabel.frame = rect
            
        }, completion: { (_) in
            UIView.animate(withDuration: 0.5, animations: {
                rect.size.height = 0
                self.pulldownMessageLabel.frame = rect
                
            })
        }) 
        
    }
    
    fileprivate func endLoadingData() {
        self.refreshControl?.endRefreshing()
        self.pullupView.stopAnimating()
    }
    
    
    //  MARK: - 图片点击事件
    fileprivate func clickedPictureView(_ notification: Notification){
        guard let urls = (notification as NSNotification).userInfo![kStatusPictureViewSelectedPhotoURLsKey] as? [URL] else {
            return
        }
        guard let indexPath = (notification as NSNotification).userInfo![kStatusPictureViewSelectedPhotoIndexPathKey] as? IndexPath else {
            return
        }
        //  获取图片视图的对象
        guard let picView = notification.object as? CFStatusPictureView else {
            return
        }
        
        
        //  Modal 展现，默认会将上级视图
        let vc = CFPhotoBrowserVC(urls: urls, placeholderImages: picView.images, indexPath: indexPath)
        //  这两句代码，可以保证原控制器不会被移除
        //  1. 指定动画的提供者 transitioning - 转场，从一个界面跳转到另外一个界面的动画效果
        vc.transitioningDelegate = self.photoBrowserAnimator
        //  2. 指定 modal 展现样式是自定义
        vc.modalPresentationStyle = UIModalPresentationStyle.custom
        //  3. 计算位置
        
        self.photoBrowserAnimator.prepareAnimator(picView.screenRect(indexPath), toRect: picView.fullScreenRect(indexPath), url: urls[(indexPath as NSIndexPath).item], placeholderImage: picView.images![(indexPath as NSIndexPath).item], picView: picView)
        //  这里会对 self 强引用，进行copy。下面的deinit不会被执行到。
        self.present(vc, animated: true, completion: nil)

    }

}

//  类似于 OC 分类。同时可以将遵守的协议分离出来
//  MARK: - 代理回调
extension CFHomeTableVC: CFStatusCellDelegate {
    //  MARK: -- CFStatusCellDelegate
    func statusCellDidSelectedLinkText(_ text: String) {
//        print("超链接文字: \(text)")
        guard let url = URL(string: text) else { return }
        let vc = CFHomeWebVC()
        vc.url = url
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //  MARK: -- UITableViewDelegate,UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statusListVM.statusList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //  获得可重用 cell 的同时要获得行高
        let statusVM = statusListVM.statusList[(indexPath as NSIndexPath).row]
        let statusCell = tableView.dequeueReusableCell(withIdentifier: statusVM.statusCellIdentifier, for: indexPath) as! CFStatusCell
        statusCell.statusCellDelegate = self
        statusCell.statusVM = statusVM
        
        //  判断当前的 indexpath 是否是驻足的最后一项，如果是开始上拉动画
        if (indexPath as NSIndexPath).row == statusListVM.statusList.count - 1 {
            pullupView.startAnimating()
            loadData()
        }
        
        return statusCell;
    }

    /*
        默认情况下会计算所有的行高，原因：UITableView 继承自 UIScrollView 
        UIScrollView 的滚动依赖于 contentSize -> 把所有行高都计算出来，才能准确知道 contentsize
        如果设置了预估行高，会根据预估行高，来计算需要显示的尺寸
        工作原理： 1. 预估行高估算整体高度 2. 显示 cell 的时候，计算当前要显示的实际行高 3. 当表格继续滚动的时候，边滚动边计算，效率不高，单是不需要一次性把所有行高都计算出来
        提示： 如果行高是固定的，千万不要实现此代理方法，行高的代理方法，在每个版本的 xcode 和 ios 模拟器上执行的频率都不一样，苹果一直在底层做优化
        
        行高的缓存，只计算一次，提高效率
    */
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let statusVM = statusListVM.statusList[(indexPath as NSIndexPath).row]
        //  判断视图模型行高是否为 0， 为 0 时计算行高并负值
        if statusVM.statusCellHeight ==  0 {

            let cell = tableView.dequeueReusableCell(withIdentifier: statusVM.statusCellIdentifier) as! CFStatusCell
            statusVM.statusCellHeight = cell.rowHeitht(statusVM)
            
        }
        
        return statusVM.statusCellHeight
    }
}

//  MARK: - 视图创建
extension CFHomeTableVC {
    fileprivate func preparePhotoBrowserModal() {
        /**
         注册通知
         name:       通知名
         object:     监听发送通知的对象 如果是 nil 就在主线程调度 block 执行
         queue:      队列，执行 block 的队列
         block:      接收到通知执行的方法
         使用通知的 block 只要使用 self 一定会循环引用
         */
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kStatusPictureViewSelectedPhotoNotification), object: nil, queue: nil) { [weak self] (notification) in
            //            printLog(notification)
            //            printLog(NSThread.currentThread())
            
            self?.clickedPictureView(notification)
        }

    }
    
    fileprivate func prepareNavigation() {

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(imageName: "navigationbar_pop", target: self, selector: #selector(CFHomeTableVC.qrCodeShow))
        
        
    }
    
    fileprivate func prepareTableView() {
        //  注册 cell
        self.tableView.register(CFForwardStatusCell.self, forCellReuseIdentifier: kForwardStatusCellIdentifier)
        self.tableView.register(CFOriginalityStatusCell.self, forCellReuseIdentifier: kOriginalityStatusIdentifier)
        //  一下两句可以自动处理行高（提示：如果不使用自动计算行号 UITableViewAutomaticDimension 一定不要设置底部约束）
        tableView.estimatedRowHeight = 300
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        //  准备下拉刷新控件
        refreshControl = CFRefreshControl()
        //        (refreshControl as! CFRefreshControl).addRefreshing(self, selector: #selector(loadData))
        refreshControl?.addTarget(self, action: #selector(loadData), for: UIControlEvents.valueChanged)
        
        //  准备上拉提示控件
        tableView.tableFooterView = pullupView
        
    }

}
