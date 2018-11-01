//
//  UViewController+Navigation.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/14.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import UIKit

extension UIViewController {

    func setupNavigationItem() {
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIImageView(image: #imageLiteral(resourceName: "title")))
    }
}
