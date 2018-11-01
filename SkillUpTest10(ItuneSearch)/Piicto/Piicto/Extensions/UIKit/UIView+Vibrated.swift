//
//  UIView+Vibrated.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/27.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import UIKit

extension UIView {

    private func degreesToRadians(degrees: CGFloat) -> CGFloat {
        return degrees * CGFloat(Double.pi) / CGFloat(180.0)
    }

    func vibrated(vibrated: Bool) {

        let vibrateAnimationKey = "VibrateAnimationKey"

        if vibrated {
            var animation: CABasicAnimation
            animation = CABasicAnimation(keyPath: "transform.rotation")
            animation.duration = 0.2
            animation.fromValue = degreesToRadians(degrees: 1.0)
            animation.toValue = degreesToRadians(degrees: -1.0)
            animation.repeatCount = .infinity
            animation.autoreverses = true
            self.layer.add(animation, forKey: vibrateAnimationKey)
        } else {
            self.layer.removeAnimation(forKey: vibrateAnimationKey)
        }
    }
}
