//
//  PiictoNavigationController.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/14.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import UIKit

final class PiictoNavigationController: UINavigationController {

    override var childViewControllerForStatusBarHidden: UIViewController? {
        return visibleViewController
    }

    override var childViewControllerForStatusBarStyle: UIViewController? {
        return visibleViewController
    }
}
