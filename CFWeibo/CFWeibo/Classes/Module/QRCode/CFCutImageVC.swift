//
//  CFCutImageVC.swift
//  CFWeibo
//
//  Created by 成飞 on 16/6/23.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit

//  MARK: - TODO:
class CFCutImageVC: UIViewController {

    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(image: selectedImage)
        if let image = selectedImage {
            let point = CGPoint(x: 0, y: (kScreenHeight - image.size.height) * 0.5)
            imageView.frame = CGRect(origin: point, size: image.size)
            scrollView.addSubview(imageView)
        }
        
        cutView.layer.borderWidth = 1
        cutView.layer.borderColor = UIColor.lightGrayColor().CGColor
    
        
    }
    
    @IBOutlet weak var cutView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    
    
}
