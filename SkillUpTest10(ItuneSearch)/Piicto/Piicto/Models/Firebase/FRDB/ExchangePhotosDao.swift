//
//  ExchangePhotosDao.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/22.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import FirebaseDatabase

final class ExchangePhotosDao {

    let exchangePhotosReference = Database.database().reference().child("exchange_photos")

    func removeObservers() {
        guard let uid = UserDefaults.standard.string(forKey: .uid) else {
            return
        }
        exchangePhotosReference.child(uid).removeAllObservers()
    }

    func communicationWithDefaultUserOrNot(completionBlock: @escaping (Bool) -> Void) {
        guard let uid = UserDefaults.standard.string(forKey: .uid) else {
            return
        }
        let exchangePhotosWithMeReference = exchangePhotosReference.child(uid)
        exchangePhotosWithMeReference.observeSingleEvent(of: .value) { snapshot in
            
            let partners = snapshot.value as? [String: Any] ?? [:]
            if partners.first?.key == CommunicateDefaultUser.defaultUserID {
                completionBlock(true)
                return
            }
            completionBlock(false)
        }
    }

    func communicationWithDefaultUserCount(completionBlock: @escaping (Int?) -> Void) {
        guard let uid = UserDefaults.standard.string(forKey: .uid) else {
            completionBlock(nil)
            return
        }
        let exchangePhotosWithMeReference = exchangePhotosReference.child(uid)
        exchangePhotosWithMeReference.observeSingleEvent(of: .value) { snapshot in

            let partners = snapshot.value as? [String: Any] ?? [:]
            if partners.first?.key == CommunicateDefaultUser.defaultUserID {

                let exchanges = partners.first?.value as? [String: Any]
                completionBlock(exchanges?.count)
            }
            completionBlock(nil)
        }
    }

    // MARK: - Data Access

    func write(exchangePhotoEntity: ExchangePhotoEntity, completionBlock: ((Error?, DatabaseReference) -> Void)? = nil) {

        guard let uid = UserDefaults.standard.string(forKey: .uid) else {
            return
        }

        if let completionBlock = completionBlock {
            let exchangePhotosWithMeReference = exchangePhotosReference.child(uid)
            exchangePhotosWithMeReference
                .child(exchangePhotoEntity.partnerID)
                .child(exchangePhotoEntity.photo.photoID)
                .setValue(exchangePhotoEntity.photo.visible, withCompletionBlock: completionBlock)
        } else {
            let exchangePhotosWithMeReference = exchangePhotosReference.child(uid)
            exchangePhotosWithMeReference
                .child(exchangePhotoEntity.partnerID)
                .child(exchangePhotoEntity.photo.photoID)
                .setValue(exchangePhotoEntity.photo.visible)
        }
    }

    func update(exchangePhotoEntity: ExchangePhotoEntity) {
        guard let uid = UserDefaults.standard.string(forKey: .uid) else {
            return
        }
        let exchangePhotosWithMeReference = exchangePhotosReference.child(uid)
        exchangePhotosWithMeReference
            .child(exchangePhotoEntity.partnerID)
            .updateChildValues(value(exchangePhotoEntity: exchangePhotoEntity))
    }

    private func value(exchangePhotoEntity: ExchangePhotoEntity) -> [String: Any] {
        return [
            exchangePhotoEntity.photo.photoID: exchangePhotoEntity.photo.visible
        ]
    }
}
