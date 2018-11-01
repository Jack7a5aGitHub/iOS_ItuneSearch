//
//  SendModalViewController.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/23.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import UIKit

final class SendModalViewController: UIViewController {

    @IBOutlet private var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView! // swiftlint:disable:this private_outlet

    private let sendModalViewStatusBar = SendModalViewStatusBar()

    private var imageSlideOutTransition = ImageSlideOutTransition()
    private var interactiveTransitionController: UIPercentDrivenInteractiveTransition?
    private var isTransitioning = false
    private var image = UIImage()
    private var imageName = ""

    // MARK: - Factory
    
    class func make(with image: UIImage, name: String) -> SendModalViewController {

        let vcName = SendModalViewController.className
        guard let sendModalVC = UIStoryboard.viewController(
            storyboardName: vcName,
            identifier: vcName) as? SendModalViewController else {
                fatalError("SendViewController is nil.")
        }
        sendModalVC.image = image
        sendModalVC.imageName = name
        return sendModalVC
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        setNeedsStatusBarAppearanceUpdate()
        sendModalViewStatusBar.setStatusBarBackgroundColor(newColor: #colorLiteral(red: 1, green: 0.5294117647, blue: 0.4705882353, alpha: 1))
        imageView.image = image
        self.transitioningDelegate = self
        panGestureRecognizer.delegate = self
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Actions
    @IBAction func didTapBack(_ sender: UIButton) {

        guard
            let piictoNC = presentingViewController as? PiictoNavigationController,
            let sendVC = piictoNC.viewControllers.last as? SendViewController
            else {
                return
        }
        sendVC.sendStatus = .willBack
        dismiss(animated: false) {
            self.sendModalViewStatusBar.setStatusBarBackgroundColor(newColor: nil)
            piictoNC.popViewController(animated: true)
        }
    }
}

extension SendModalViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return imageSlideOutTransition
    }

    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {

        return self.interactiveTransitionController
    }
}

extension SendModalViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        if otherGestureRecognizer.isKind(of: UIPinchGestureRecognizer.self) {
            return false
        } else {
            return true
        }
    }
}

extension SendModalViewController {
    // MARK: - Selectors
    @IBAction func pan(_ sender: UIPanGestureRecognizer) {

        if scrollView.zoomScale > 1.0 || scrollView.contentOffset.x != 0 {
            return
        }

        switch sender.state {
        case .began:
            // ジェスチャの開始。遷移を開始・上下方向を決定する。
            panBegan(sender: sender)

        case .cancelled:
            // ジェスチャキャンセル。遷移をキャンセルする
            endTransitioning()
            cancelInteractiveTransition()

        case .changed:
            // ジェスチャ中。遷移の進行度を更新する
            panChanged(sender: sender)

        case .ended:
            // ジェスチャの正常完了。遷移を実行させるかキャンセルする。
            endTransitioning()

            guard let interactiveTransitionController = interactiveTransitionController else {
                break
            }

            // 進行度0.5以上なら遷移実行へ
            if interactiveTransitionController.percentComplete >= CGFloat(0.5) {
                finishInteractiveTransition()
                break
            }

            // スワイプの勢いが一定以上なら遷移実行へ
            determineTheSwipeSpeed(sender: sender)

        case .failed:
            // ジェスチャの失敗。遷移をキャンセルする。
            panFailed()

        default:
            break
        }
    }

    private func panBegan(sender: UIPanGestureRecognizer) {
        isTransitioning = true
        scrollView.isScrollEnabled = false
        interactiveTransitionController = UIPercentDrivenInteractiveTransition()

        if sender.translation(in: scrollView).y > 0 {
            imageSlideOutTransition.isScrolledUp = false
        } else {
            imageSlideOutTransition.isScrolledUp = true
        }
        dismiss(animated: true, completion: nil)
        updateTransitionProgress(sender: sender)
    }

    private func panChanged(sender: UIPanGestureRecognizer) {
        if isTransitioning {
            // 方向が変更される場合、一旦キャンセルして初期化し直す
            if imageSlideOutTransition.isScrolledUp && sender.translation(in: scrollView).y > 0 {
                reInitDismiss(isScrolledUp: false)
            } else if !imageSlideOutTransition.isScrolledUp && sender.translation(in: scrollView).y < 0 {
                reInitDismiss(isScrolledUp: true)
            }
            updateTransitionProgress(sender: sender)
        }
    }

    private func determineTheSwipeSpeed(sender: UIPanGestureRecognizer) {
        let velocityinView = sender.velocity(in: scrollView).y
        print("velocityinView: \(fabs(velocityinView))")
        if fabs(velocityinView) > 1000 {
            if imageSlideOutTransition.isScrolledUp && velocityinView < 0 {
                finishInteractiveTransition()
            } else if !imageSlideOutTransition.isScrolledUp && velocityinView > 0 {
                // 下へスクロールした場合は、キャンセル
                cancelInteractiveTransition()
            } else {
                cancelInteractiveTransition()
            }
        } else {
            cancelInteractiveTransition()
        }
    }

    private func panFailed() {
        endTransitioning()
        cancelInteractiveTransition()
    }
}

extension SendModalViewController {

    /// 遷移の進行度を更新する
    private func updateTransitionProgress(sender: UIPanGestureRecognizer) {
        let transitionProgress: CGFloat = sender.translation(in: scrollView).y / view.frame.size.height
        interactiveTransitionController?.update(fabs(transitionProgress))
    }

    /// 遷移フラグを折って、スクロールビューのスクロールを許可する
    private func endTransitioning() {
        isTransitioning = false
        scrollView.isScrollEnabled = true
    }

    /// 方向が変更される場合、一旦キャンセルして初期化し直す
    private func reInitDismiss(isScrolledUp: Bool) {
        interactiveTransitionController?.cancel()
        interactiveTransitionController = UIPercentDrivenInteractiveTransition()
        imageSlideOutTransition.isScrolledUp = isScrolledUp
        dismiss(animated: true, completion: nil)
    }

    /// 画面遷移を実行する
    private func finishInteractiveTransition() {
        
        guard
            let piictoNC = presentingViewController as? PiictoNavigationController,
            let sendVC = piictoNC.viewControllers.last as? SendViewController
            else {
                return
        }
        sendVC.sendStatus = .willSend
        interactiveTransitionController?.finish()
        interactiveTransitionController = nil
    }

    /// 画面遷移を実行しない
    private func cancelInteractiveTransition() {
        interactiveTransitionController?.cancel()
        interactiveTransitionController = nil
    }
}
