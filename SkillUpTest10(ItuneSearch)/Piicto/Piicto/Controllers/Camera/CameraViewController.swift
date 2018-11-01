//
//  CameraViewController.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/24.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import AssetsLibrary
import Photos
import SwiftyCam
import UIKit

final class CameraViewController: SwiftyCamViewController, SwiftyCamViewControllerDelegate {

    @IBOutlet private weak var swiftyCamButton: SwiftyCamButton!

    // MARK: - Factory

    class func make() -> CameraViewController {
        let vcName = CameraViewController.className
        guard let cameraVC = UIStoryboard.viewController(
            storyboardName: vcName, identifier: vcName) as? CameraViewController else {
                fatalError("CameraViewController is nil.")
        }
        return cameraVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        cameraDelegate = self

        swiftyCamButton.delegate = self
        view.bringSubview(toFront: swiftyCamButton) // カメラのプレビューより上に配置する
    }

    @IBAction func didTapBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        print("写真が撮影されました")

        // フォトライブラリに保存
        UIImageWriteToSavedPhotosAlbum(photo,
                                       self,
                                       #selector(showResultOfSaveImage(_:didFinishSavingWithError:contextInfo:)),
                                       nil)
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        print("ビデオが撮影されました")

        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }, completionHandler: { saved, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if saved {
                let options = PHFetchOptions()
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

                guard let latestAsset = PHAsset.fetchAssets(
                    with: .video,
                    options: options).firstObject else {
                        return
                }

                // 送信画面に遷移
                let photoFetchAssets = PhotoFetchAssets()
                photoFetchAssets.requestAVAsset(asset: latestAsset, completionBlock: { previewImage, imageName in
                    guard
                        let previewImage = previewImage,
                        let imageName = imageName else {
                            return
                    }
                    let sendVC = SendViewController.make(with: previewImage, name: imageName, destinationID: nil)
                    self.navigationController?.pushViewController(sendVC, animated: true)
                })
            }
        })
    }

    // 保存を試みた結果をダイアログで表示
    @objc func showResultOfSaveImage(_ image: UIImage,
                                     didFinishSavingWithError error: Error?,
                                     contextInfo: UnsafeMutableRawPointer) {

        if let error = error {
            print(error.localizedDescription)
            return
        }

        let fetchResult = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .smartAlbumUserLibrary,
            options: nil
        )

        guard let assetCollection = fetchResult.firstObject else {
            return
        }

        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        guard let latestAsset = PHAsset.fetchAssets(in: assetCollection, options: options).firstObject else {
            return
        }

        // 送信画面に遷移
        let photoFetchAssets = PhotoFetchAssets()
        photoFetchAssets.requestImage(asset: latestAsset) { image, imageName in
            guard
                let image = image,
                let imageName = imageName else {
                    return
            }
            let sendVC = SendViewController.make(with: image, name: imageName, destinationID: nil)
            self.navigationController?.pushViewController(sendVC, animated: true)
        }
    }
}
