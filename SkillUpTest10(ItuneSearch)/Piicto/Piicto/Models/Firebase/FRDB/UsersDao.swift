//
//  UsersDao.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/21.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import FirebaseDatabase
import FirebaseMessaging

final class UsersDao {

    static let usersReference = Database.database().reference().child("users")

    private static func value(userEntity: UserEntity) -> [String: Any] {
        return [
            UserEntityKey.userID: userEntity.userID,
            UserEntityKey.name: userEntity.name,
            UserEntityKey.profileImgURL: userEntity.profileImgURL,
            UserEntityKey.longitude: userEntity.longitude,
            UserEntityKey.latitude: userEntity.latitude,
            UserEntityKey.totalHeart: userEntity.totalHeart,
            UserEntityKey.facebookID: userEntity.facebookID,
            UserEntityKey.instagramID: userEntity.instagramID,
            UserEntityKey.token: userEntity.token
        ]
    }
//    init() {
//        var userArray = [String]()
//        UsersDao.usersReference.observe(.value) { snapshot in
//            EntityManager.shared.users = []
//            let users = snapshot.value as? [String: Any] ?? [:]
//            for user in users {
//                guard let value = user.value as? [String: Any] else {
//                    continue
//                }
//                var userEntity = UserEntity()
//                userEntity.name = user.key
//                print("============")
//                print(userEntity)
//                print("============")
//                userArray.append(user.key)
//            }
//            print(userArray)
//            print(userArray.count)
//        }
//    }

    /// 初回起動時のuid, 位置情報登録
    static func writeInitialUserData(latitude: Double,
                                     longitude: Double,
                                     completionBlock: @escaping (Error?, DatabaseReference) -> Void) {

        guard let uid = UserDefaults.standard.string(forKey: .uid) else {
            return
        }
        
        var userEntity = UserEntity()
        userEntity.userID = uid
        userEntity.name = "no name"
        userEntity.profileImgURL = ""
        userEntity.longitude = longitude
        userEntity.latitude = latitude
        userEntity.totalHeart = 0
        userEntity.facebookID = 0
        userEntity.instagramID = 0
        userEntity.token = Messaging.messaging().fcmToken ?? ""
        UsersDao.write(userEntity: userEntity, completionBlock: completionBlock)
        
    }

    /// userIDを指定して、名前とプロフィール画像のURLを取得する
    ///
    /// - Parameter userID: userID
    /// - Returns: 表示名、プロフィール画像のURLを含むUserEntity
    static func userInfo(userID: String, completionBlock: @escaping (UserEntity) -> Void) {

        if userID.isEmpty {
            return
        }
        usersReference.child(userID).observeSingleEvent(of: .value) { snapshot in
            let user = snapshot.value as? [String: Any] ?? [:]
            var userEntity = UserEntity()
            userEntity.userID = userID
            userEntity.name = "\(user[UserEntityKey.name] ?? "")"
            userEntity.profileImgURL = "\(user[UserEntityKey.profileImgURL] ?? "")"
            userEntity.longitude = user[UserEntityKey.longitude] as? Double ?? 0
            userEntity.latitude = user[UserEntityKey.latitude] as? Double ?? 0
            userEntity.totalHeart = user[UserEntityKey.totalHeart] as? Int ?? 0
            userEntity.facebookID = user[UserEntityKey.facebookID] as? Int ?? 0
            userEntity.instagramID = user[UserEntityKey.instagramID] as? Int ?? 0
            userEntity.token = user[UserEntityKey.token] as? String ?? ""

            completionBlock(userEntity)
        }
    }

    /// プロフィール画面で表示するTotalHeart
    ///
    /// - Returns: ハートの数
    static func totalHeart() -> Int {
        guard let uid = UserDefaults.standard.string(forKey: .uid) else {
            return 0
        }
        return usersReference.child(uid).value(forKey: UserEntityKey.totalHeart) as? Int ?? 0
    }

    // MARK: - Data Access

    static func write(userEntity: UserEntity, completionBlock: ((Error?, DatabaseReference) -> Void)? = nil) {
        if let completionBlock = completionBlock {
            usersReference.child(userEntity.userID).setValue(value(userEntity: userEntity),
                                                             withCompletionBlock: completionBlock)
        } else {
            usersReference.child(userEntity.userID).setValue(value(userEntity: userEntity))
        }
    }

    static func update(userEntity: UserEntity, completionBlock: ((Error?, DatabaseReference) -> Void)? = nil) {
        if let completionBlock = completionBlock {
            usersReference.child(userEntity.userID).updateChildValues(value(userEntity: userEntity),
                                                                      withCompletionBlock: completionBlock)
        } else {
            usersReference.child(userEntity.userID).updateChildValues(value(userEntity: userEntity))
        }
    }

    /// Unused code.
    static func remove(userEntity: UserEntity) {
        usersReference.child(userEntity.userID).removeValue()
    }
}
