//
//  HorizontalPageViewController.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/08.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import FirebaseDatabase
import UIKit

/// メイン画面のページング
final class HorizontalPageViewController: UIPageViewController {

    @IBOutlet private weak var configurationBarButton: UIBarButtonItem!

    private var exchangePhotosReference: DatabaseReference?
    private var index = 0

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        setupNavigationItem()
        let photos = EntityManager.shared.exchangePhotos
            .filter { $0.partnerID == EntityManager.shared.partnerIDArray[0] }
        let vcArray = [MainViewController.make(exchangePhotoEntityArray: photos, index: index)]

        setViewControllers(vcArray, direction: .forward, animated: true, completion: nil)
        
       
        self.dataSource = self
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Action
    
    @IBAction func transitionProfile(_ sender: Any) {
        let profileVC = ProfilePageViewController.make(partnerId: nil)
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
}

extension HorizontalPageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {

        if viewController.isKind(of: NewSendViewController.self) {
 
            return nil
        } else if index == 0 {
            return NewSendViewController.make()
        } else {
            index -= 1
            guard let partnerID = EntityManager.shared.partnerIDArray[safe: self.index] else {
                index += 1
                
                return NewSendViewController.make()
            }
            
            let photos = EntityManager.shared.exchangePhotos.filter { $0.partnerID == partnerID }
            return MainViewController.make(exchangePhotoEntityArray: photos, index: index)
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {

        if viewController.isKind(of: NewSendViewController.self) {
             print("check index : \(index)")
            return toMainViewController()
        } else {
            index += 1

            // MARK: やりとり可能なユーザは15名
            if index == 14 {
                 print("check index : \(index)")
                return nil
            }
             print("check index : \(index)")
            return toMainViewController()
        }
    }
}

extension HorizontalPageViewController {

    private func toMainViewController() -> MainViewController? {
        guard let partnerID = EntityManager.shared.partnerIDArray[safe: self.index] else {
            return nil
        }
        let photos = EntityManager.shared.exchangePhotos.filter { $0.partnerID == partnerID }
        return MainViewController.make(exchangePhotoEntityArray: photos, index: index)
    }
}
