//
//  UIStoryboard+Instance.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/08.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import UIKit

extension UIStoryboard {

    /// Storyboardからインスタンスを取得する
    class func viewController <T: UIViewController> (storyboardName: String, identifier: String) -> T? {
        
        return UIStoryboard(name: storyboardName, bundle: nil)
            .instantiateViewController(withIdentifier: identifier) as? T
    }
}
