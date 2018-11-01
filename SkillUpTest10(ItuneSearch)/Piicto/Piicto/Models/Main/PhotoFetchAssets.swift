//
//  PhotoFetchAssets.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/24.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import Photos
import UIKit

final class PhotoFetchAssets {

    func requestImage(asset: PHAsset, completionBlock: @escaping (UIImage?, String?) -> Void) {
        let option = PHImageRequestOptions()
        option.deliveryMode = .highQualityFormat

        let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: option) { image, info in

                guard
                    let url = info?["PHImageFileURLKey"] as? URL,
                    let image = image else {
                        print("写真の取得に失敗しました。")
                        completionBlock(nil, nil)
                        return
                }
                print("選択された画像のファイル名: \(url.lastPathComponent)")
                print("選択された画像の拡張子: \(url.pathExtension)")
                // 送信画面に遷移
                completionBlock(image, url.lastPathComponent)
        }
    }

    func requestAVAsset(asset: PHAsset, completionBlock: @escaping (UIImage?, String?) -> Void) {
        let option = PHVideoRequestOptions()
        option.deliveryMode = .highQualityFormat

        PHImageManager.default().requestAVAsset(
            forVideo: asset,
            options: option,
            resultHandler: { avAsset, _, info in

                guard let tokenStr = info?["PHImageFileSandboxExtensionTokenKey"] as? String else {
                    print("PHImageFileSandboxExtensionTokenKey is nil.")
                    return
                }

                let tokenKeys = tokenStr.components(separatedBy: ";")
                let urlString = tokenKeys.first(where: { key -> Bool in
                    key.contains("/private/var/mobile/Media")
                })

                if let urlString = urlString,
                    let url = URL(string: urlString) {

                    print("選択された動画のファイル名: \(url.lastPathComponent)")
                    print("選択された動画の拡張子: \(url.pathExtension)")

                    do {
                        guard let avAsset = avAsset else {
                            completionBlock(nil, nil)
                            return
                        }
                        // assetから画像作成の為のジェネレーターを作成。
                        let generator = AVAssetImageGenerator(asset: avAsset)
                        generator.maximumSize = CGSize(width: 1200, height: 1600)
                        // 指定した時間のUIImageを作成
                        let midpoint = CMTimeMakeWithSeconds(0.0, 30)
                        let capturedImage = try generator.copyCGImage(at: midpoint, actualTime: nil)
                        completionBlock(UIImage(cgImage: capturedImage), url.lastPathComponent)
                    } catch let error {
                        print(error.localizedDescription)
                    }

                } else {
                    print("動画ファイル名の取得に失敗しました。")
                    completionBlock(nil, nil)
                }
        })
    }
}
