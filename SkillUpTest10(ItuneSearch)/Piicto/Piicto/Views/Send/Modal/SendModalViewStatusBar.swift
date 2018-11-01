//
//  SendModalViewStatusBar.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/23.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import UIKit

final class SendModalViewStatusBar: NSObject {

    func setStatusBarBackgroundColor(newColor: UIColor?) {
        guard
            let statusBarWindow = UIApplication.shared.value(forKey: "statusBarWindow") as? UIView,
            let statusBar = statusBarWindow.subviews.first
            else {
                return
        }
        statusBar.backgroundColor = newColor
    }
}
