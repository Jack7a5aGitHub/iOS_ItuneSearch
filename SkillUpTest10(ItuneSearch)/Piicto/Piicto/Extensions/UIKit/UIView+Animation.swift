//
//  UIView+Animation.swift
//  Piicto
//
//  Created by kawaharadai on 2018/01/25.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import Foundation
import UIKit

enum FadeType: TimeInterval {
    case normal = 0.7
    case slow = 1.0
}

extension UIView {
    func fadeInAnimation(type: FadeType = .normal, completed: (() -> Void)? = nil) {
        fadeIn(duration: type.rawValue, completed: completed)
    }
    
    func fadeIn(duration: TimeInterval = FadeType.slow.rawValue, completed: (() -> Void)? = nil) {
        alpha = 0
        isHidden = false
        UIView.animate(withDuration: duration,
                       animations: {
                        self.alpha = 1
        })
    }
    
    func fadeOut(type: FadeType = .normal, completed: (() -> Void)? = nil) {
        fadeOut(duration: type.rawValue, completed: completed)
    }
    
    func fadeOut(duration: TimeInterval = FadeType.slow.rawValue, completed: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: duration,
            animations: {
                self.alpha = 0
        },
            completion: { [weak self] finished in
                self?.isHidden = true
                self?.alpha = 1
                completed?()
        })
    }
}
