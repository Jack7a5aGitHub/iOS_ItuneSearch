//
//  PiictoStorage.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/21.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import FirebaseStorage
import UIKit

final class PiictoStorage {

    #if DEVELOPMENT
    static let storageURL = "gs://ios-piicto-dev.appspot.com/"
    #elseif STAGING
    static let storageURL = "gs://piicto-dev.appspot.com/"
    #else
    // FIXME: リリース版は、Stagingと同じにしておく。リリース前にGoogleService-Info.plistを作成して、ここも修正する。
    static let storageURL = "gs://piicto-dev.appspot.com/"
    #endif

    /// FirebaseStorageから画像ダウンロード用のURLを取得する
    static func downloadURL(uid: String, imageName: String, completionBlock: @escaping (URL?) -> Void) {

        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: PiictoStorage.storageURL)
        let imageRef = storageRef.child(uid).child(imageName)

        imageRef.downloadURL { url, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            completionBlock(url)
        }
    }

    static func uploadImage(uid: String,
                            destinationID: String?,
                            imageName: String,
                            imageData: Data,
                            newPosts: @escaping (String?) -> Void) {

        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: storageURL)
        let imageRef = storageRef.child(uid).child(imageName)
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("error: \(error.localizedDescription)")
                return
            }
            guard let metadata = metadata else {
                print("metadata is nil.")
                return
            }
            guard let downloadURL = metadata.downloadURL() else {
                print("downloadURL is nil.")
                return
            }

            print("uploaded image url: \(downloadURL)")
            // Photosテーブルに新規イメージを登録する
            EntityManager.shared.photosDao.insertNewPhoto(
                photoPath: imageName,
                destinationID: destinationID) { photoID in

                    if let newPhotoID = photoID {
                        newPosts(newPhotoID)
                    } else {
                        newPosts(nil)
                    }
            }
        }
    }
}
