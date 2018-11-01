//
//  UIImage+Resize.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/30.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import UIKit

extension UIImage {
    func resize(size: CGSize) -> UIImage? {
        let widthRatio = size.width / size.width
        let heightRatio = size.height / size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio

        let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0) // 変更
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }
}
