
//
//  Alert.swift
//  Piicto
//
//  Created by kawaharadai on 2018/01/28.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import UIKit

protocol AlertDelegate: class {
    func instagramAuth()
    func facebookAuth()
}

class Alert: NSObject {
    
    weak var tapAction: AlertDelegate?
    
    func authAlert(title: String,
                   message: String,
                   instagramAuthTitle: String,
                   facebookAuthTitle: String) -> UIAlertController {
        
        let authAlert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: UIAlertControllerStyle.alert)
        
        let instagramAuthAction = UIAlertAction(title: instagramAuthTitle,
                                                style: UIAlertActionStyle.default,
                                                handler: { _ in
                                                    self.tapAction?.instagramAuth()
                                                    
        })
        
        let facebookAuthAction = UIAlertAction(title: facebookAuthTitle,
                                               style: UIAlertActionStyle.default,
                                               handler: { _ in
                                                self.tapAction?.facebookAuth()
        })
        
        let cancelAction = UIAlertAction(title: "キャンセル",
                                         style: UIAlertActionStyle.cancel,
                                         handler: { _ in
                                            print("キャンセル")
                                            
        })
        
        authAlert.addAction(instagramAuthAction)
        authAlert.addAction(facebookAuthAction)
        authAlert.addAction(cancelAction)
        
        return authAlert
    }
}
