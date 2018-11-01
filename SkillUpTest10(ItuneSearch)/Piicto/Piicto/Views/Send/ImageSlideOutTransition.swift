//
//  ImageSlideOutTransition.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/23.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import UIKit

/// Modalを閉じて元のVCを表示する際のアニメーション定義
final class ImageSlideOutTransition: NSObject, UIViewControllerAnimatedTransitioning {

    var isScrolledUp = false

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.75
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard
            let fromVC = transitionContext.viewController(forKey: .from) as? SendModalViewController,
            let toVC = transitionContext.viewController(forKey: .to) else {
                return
        }

        // 遷移先のVCが遷移元のVCの下に現れるようにする
        let containerView = transitionContext.containerView
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)

        UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                       delay: 0.0,
                       options: .curveLinear, animations: {
                        var fromVCImageViewRect = fromVC.imageView.frame
                        // ドラッグの方向で、どちらに画像がスライドするのか決定
                        if self.isScrolledUp {
                            fromVCImageViewRect.origin.y = -fromVC.view.frame.size.height
                        } else {
                            fromVCImageViewRect.origin.y = fromVC.view.frame.size.height
                        }
                        fromVC.imageView.frame = fromVCImageViewRect

                        // 遷移元のVCのimageViewを薄く、遷移先のVCをはっきり表示
                        fromVC.view.alpha = 0.0
                        toVC.view.alpha = 1.0
        }, completion: { _ in
            let isCompleted = !transitionContext.transitionWasCancelled
            transitionContext.completeTransition(isCompleted)
        })
    }
}
