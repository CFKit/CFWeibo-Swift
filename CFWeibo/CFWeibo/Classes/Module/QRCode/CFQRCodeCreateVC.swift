
//  CFQRCodeCreateVC.swift
//  CFWeibo
//
//  Created by 成飞 on 16/6/22.
//  Copyright © 2016年 成飞. All rights reserved.
//

import UIKit
import SVProgressHUD

class CFQRCodeCreateVC: UIViewController {

    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func createQRCodeClicked(_ sender: AnyObject) {
        
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            
            if let image = createQRCode(textField.text ?? "", avatarImage: nil) {
                self.iconImageView.image = image
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(CFQRCodeCreateVC.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
            return
        }
        
        //  访问相册
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        //        imagePickerVC.allowsEditing = true
        self.present(imagePickerVC, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.iconImageView.image = createQRCode("我喜欢伊晓丹", avatarImage: nil)
    }
    
    /**
     *  CoreImage 框架 滤镜、GIF动图、二维码
     *  CoreGraphics: 核心图形，绘图
     *
     *  使用滤镜生成的 二维码 不清楚
     *
     *  1. 不要在二维码中包含过多的文字，生成二维码很耗性能，识别的性能也很差
     *  2. 生成的头像，不要遮挡住三个定位点
     *  3. 二维码的识别度很高，有一定的容错性。
     */
    fileprivate func createQRCode(_ string: String, avatarImage: UIImage?) -> UIImage? {
        
        //  建立一个滤镜
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        //  重设滤镜的初始值
        qrFilter?.setDefaults()
        
        //  通过 KVC 设置滤镜的内容
        qrFilter?.setValue(string.data(using: String.Encoding.utf8, allowLossyConversion: true), forKey: "inputMessage")

        guard let qrImage = qrFilter?.outputImage else { return nil }
        
        //  过滤图像色彩以及 '形变 ' 的滤镜
        let colorFilter = CIFilter(name: "CIFalseColor")
        colorFilter?.setDefaults()
        colorFilter?.setValue(qrImage, forKey: "inputImage")
        colorFilter?.setValue(CIColor(red: 1.0, green: 127.0 / 255.0, blue: 0) , forKey: "inputColor0")
        colorFilter?.setValue(CIColor(red: 1.0, green: 1.0, blue: 1.0), forKey: "inputColor1")
        
        let transform = CGAffineTransform(scaleX: 100, y: 100)
        
        guard let transformImage = colorFilter?.outputImage?.applying(transform) else { return nil }
        
        let codeImage = UIImage(ciImage: transformImage)
        return insertAvatarImage(codeImage, avatarImage: avatarImage)
    }
    
    //  合成头像
    fileprivate func insertAvatarImage(_ codeImage: UIImage, avatarImage: UIImage?) -> UIImage {
        let size = codeImage.size
        
        //  1. 开启图像上下文
        UIGraphicsBeginImageContext(size)
        
        //  2. 绘制二维码图像
        codeImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        if let avatarImg = avatarImage {
            //  3. 计算头像大小
            let w = size.width * 0.175
            let x = (size.width - size.width * 0.175) * 0.5
            avatarImg.draw(in: CGRect(x: x, y: x, width: w, height: w))
        }
        
        //  4. 从上下文中取出图像
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        //  5. 关闭上下文
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    @objc fileprivate func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        let message = (error == nil) ? "保存成功" : "保存失败"
        SVProgressHUD.showInfo(withStatus: message)
    }

}

extension CFQRCodeCreateVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        let scaleImage = image.scaleImageToWidth(kScreenWidth)
        
        if let image = createQRCode(textField.text ?? "", avatarImage: scaleImage) {
            self.iconImageView.image = image
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(CFQRCodeCreateVC.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        self.dismiss(animated: true, completion: nil)
        
//        let vc = UIStoryboard.initialViewController("QRCode", identifier: "CFCutImageVC") as! CFCutImageVC
//        vc.selectedImage = scaleImage
//        picker.navigationController?.pushViewController(vc, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
