//
//  MainViewController+UIImagePickerControllerDelegate.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/21.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import Photos
import UIKit

extension MainViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        self.dismiss(animated: true)

        let photoFetchAssets = PhotoFetchAssets()

        if let imageURL = info[UIImagePickerControllerReferenceURL] as? URL {

            guard let asset = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil).firstObject else {
                return
            }

            switch asset.mediaType {

            case .image:
                photoFetchAssets.requestImage(asset: asset, completionBlock: { image, imageName in
                    guard
                        let image = image,
                        let imageName = imageName else {
                            return
                    }

                    let sendVC = SendViewController.make(
                        with: image,
                        name: imageName,
                        destinationID: self.partnerID)
                    self.navigationController?.pushViewController(sendVC, animated: true) 
                })

            case .video:
                photoFetchAssets.requestAVAsset(asset: asset, completionBlock: { previewImage, imageName in
                    guard
                        let previewImage = previewImage,
                        let imageName = imageName else {
                            return
                    }
                    let sendVC = SendViewController.make(with: previewImage, name: imageName, destinationID: nil)
                    self.navigationController?.pushViewController(sendVC, animated: true)
                })

            default:
                break
            }
        }
    }
}

extension MainViewController: UINavigationControllerDelegate {}
