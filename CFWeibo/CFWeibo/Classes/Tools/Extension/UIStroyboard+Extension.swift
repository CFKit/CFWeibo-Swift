//
//  UIStroyboard+Extension.swift
//  CFWeibo
//
//  Created by 成飞 on 16/6/22.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    class func initialViewController(name: String) -> UIViewController {
        let sb = UIStoryboard(name: name, bundle: nil)
        
        return sb.instantiateInitialViewController()!
    }
    
    class func initialViewController(name: String, identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(identifier)
        return vc
    }
    
}
