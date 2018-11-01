//
//  SplashViewController.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/07.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import UIKit

/// スプラッシュ画面
final class SplashViewController: UIViewController {

    // MARK: - Life cycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setup()
    }

    // MARK: - Private

    private func setup() {
        confirmNetworkStatus()
    }

    private func confirmNetworkStatus() {

        guard NetworkConnection.isConnectable() else {
            showConnectionErrorAlert()
            return
        }
        transitionToHorizontalPageViewController()
    }

    private func showConnectionErrorAlert() {
        let alertController = UIAlertController(title: "ERROR".localized(),
                                                message: "CONNECTION_ERROR".localized(),
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK",
                                     style: .default) { [weak self] _ in
                                        self?.confirmNetworkStatus()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    private func transitionToHorizontalPageViewController() {
        guard let piictoNavigationController = UIStoryboard.viewController(
            storyboardName: "HorizontalPageViewController",
            identifier: "PiictoNavigationController") as? PiictoNavigationController else {
                fatalError("PiictoNavigationController is nil.")
        }
        present(piictoNavigationController, animated: false, completion: nil)
    }
}
