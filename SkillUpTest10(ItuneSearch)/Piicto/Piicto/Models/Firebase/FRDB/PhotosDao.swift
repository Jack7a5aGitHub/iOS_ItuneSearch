//
//  PhotosDao.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/21.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import FirebaseDatabase
import SVProgressHUD

/// PhotosDaoを呼び出すクラスは、インスタンスを破棄する間にremoveObservers()を呼ぶこと
final class PhotosDao {

    private let photosReference = Database.database().reference().child("photos")

    init() {
        photosReference.observe(.value) { snapshot in

            EntityManager.shared.photos = []

            let photos = snapshot.value as? [String: Any] ?? [:]
            for photo in photos {
                guard let value = photo.value as? [String: Any] else {
                    continue
                }
                var photoEntity = PhotoEntity()
                photoEntity.photoID = photo.key
                photoEntity.photoPath = "\(value[PhotoEntityKey.photoPath] ?? "")"
                photoEntity.heart = value[PhotoEntityKey.heart] as? Bool ?? false
                photoEntity.sender = "\(value[PhotoEntityKey.sender] ?? "")"
                photoEntity.longitude = value[PhotoEntityKey.longitude] as? Double ?? 0
                photoEntity.latitude = value[PhotoEntityKey.latitude] as? Double ?? 0

              //  print("---photoEntity---")
               // print(photoEntity)
               // print("------")
                EntityManager.shared.photos.append(photoEntity)
            }
        }
    }

    func removeObservers() {
        photosReference.removeAllObservers()
    }

    /// デフォルトユーザの写真を登録する
    func writeDefaultUser(photoPath: String, completionBlock: @escaping (Error?, DatabaseReference) -> Void) {

        var photoEntity = PhotoEntity()
        photoEntity.photoPath = photoPath
        photoEntity.sender = CommunicateDefaultUser.defaultUserID

        let photoReference = photosReference.childByAutoId()
        let autoId = photoReference.key
        photoReference.setValue(value(photoEntity: photoEntity, photoID: autoId))

        var exchangePhotoEntity = ExchangePhotoEntity()
        exchangePhotoEntity.partnerID = CommunicateDefaultUser.defaultUserID
        exchangePhotoEntity.photo = Photo(photoID: autoId, visible: true)
        EntityManager.shared.exchangePhotosDao.write(exchangePhotoEntity: exchangePhotoEntity,
                                                     completionBlock: completionBlock)
    }

    /// Photosテーブルに新規イメージを登録する
    ///
    /// - Parameters:
    ///   - photoPath: 画像のPATH
    ///   - destinationID: IDがある場合: 返信, nilの場合: 新規画像送信
    ///   - newPosts: 新規投稿の場合のハンドラ
    func insertNewPhoto(photoPath: String, destinationID: String?, newPosts: (String?) -> Void) {

        guard let uid = UserDefaults.standard.string(forKey: .uid),
            let latitude = UserDefaults.standard.double(forKey: .latitude),
            let longitude = UserDefaults.standard.double(forKey: .longitude) else {
                return
        }

        var photoEntity = PhotoEntity()
        photoEntity.photoPath = photoPath
        photoEntity.sender = uid
        photoEntity.heart = false
        photoEntity.latitude = latitude
        photoEntity.longitude = longitude

        let photoReference = photosReference.childByAutoId()
        let autoId = photoReference.key
        photoReference.setValue(value(photoEntity: photoEntity, photoID: autoId))

        /// destinationIDがnilではない場合は返信のためexchange_photosを更新
        guard let destinationID = destinationID else {
            newPosts(autoId)
            return
        }
        var exchangePhotoEntity = ExchangePhotoEntity()
        exchangePhotoEntity.partnerID = destinationID
        var photo = Photo()
        photo.photoID = autoId
        photo.visible = true
        exchangePhotoEntity.photo = photo
        EntityManager.shared.exchangePhotosDao.write(exchangePhotoEntity: exchangePhotoEntity)
        SVProgressHUD.dismiss()
        CommunicateDefaultUser.timeIntervalNotification()
    }

    /// photo_idを指定して、画像情報を取得する
    ///
    /// - Parameter photoID: photo_id
    /// - Returns: PhotoEntity
    func photoByPhotoID(photoID: String, completionBlock: @escaping (PhotoEntity) -> Void) {
        var photoEntity = PhotoEntity()
        photoEntity.photoID = photoID
        photosReference.child(photoID).observeSingleEvent(of: .value) { snapshot in
            let photo = snapshot.value as? [String: Any] ?? [:]
            var photoEntity = PhotoEntity()
            photoEntity.photoID = photoID
            photoEntity.photoPath = "\(photo[PhotoEntityKey.photoPath] ?? "")"
            photoEntity.heart = photo[PhotoEntityKey.heart] as? Bool ?? false
            photoEntity.sender = "\(photo[PhotoEntityKey.sender] ?? "")"
            photoEntity.longitude = photo[PhotoEntityKey.longitude] as? Double ?? 0
            photoEntity.latitude = photo[PhotoEntityKey.latitude] as? Double ?? 0

            print("---photoEntity---")
            print(photoEntity)
            print("------")
            completionBlock(photoEntity)
        }
    }

    /// photoIDを指定して、ハートを更新する
    ///
    /// - Parameters:
    ///   - photoID: photoID
    ///   - newValue: ハートのステータス
    static func updateHeart(photoID: String, newValue: Bool) {
        let photoReference = Database.database().reference().child("photos").child(photoID)
        photoReference.updateChildValues([PhotoEntityKey.heart: newValue])
    }

    // MARK: - Data Access

    func write(photoEntity: PhotoEntity) {
        let photoReference = photosReference.childByAutoId()
        let autoId = photoReference.key
        photoReference.setValue(value(photoEntity: photoEntity, photoID: autoId))
    }

    func update(photoEntity: PhotoEntity) {
        let photoReference = photosReference.child(photoEntity.photoID)
        photoReference.updateChildValues(value(photoEntity: photoEntity, photoID: photoEntity.photoID))
    }
    
    /// Unused code.
    func remove(photoEntity: PhotoEntity) {
        photosReference.child(photoEntity.photoID).removeValue()
    }

    private func value(photoEntity: PhotoEntity, photoID: String) -> [String: Any] {
        return [
            PhotoEntityKey.photoID: photoID,
            PhotoEntityKey.photoPath: photoEntity.photoPath,
            PhotoEntityKey.heart: photoEntity.heart,
            PhotoEntityKey.sender: photoEntity.sender,
            PhotoEntityKey.longitude: photoEntity.longitude,
            PhotoEntityKey.latitude: photoEntity.latitude
        ]
    }
}
