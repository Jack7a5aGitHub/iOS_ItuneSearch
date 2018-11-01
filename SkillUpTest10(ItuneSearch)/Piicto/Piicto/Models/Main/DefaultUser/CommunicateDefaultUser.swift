//
//  CommunicateDefaultUser.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/26.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import FirebaseDatabase
import Foundation
import UserNotifications

final class CommunicateDefaultUser {

    static let defaultUserID = "Yudo_User"
    static let firstPhoto = "1.png"
    static let secondPhoto = "2.png"
    static let thirdPhoto = "3.png"
    static let fourthPhoto = "4.png"

    /// デフォルトユーザから写真を受け取る
    static func receive(photoPath: String, completionBlock: @escaping (Error?, DatabaseReference) -> Void) {
        EntityManager.shared.photosDao.writeDefaultUser(photoPath: photoPath, completionBlock: completionBlock)
    }

    /// ローカル通知
    static func timeIntervalNotification() {
        let content = UNMutableNotificationContent()
        content.title = CommunicateDefaultUser.defaultUserID
        content.sound = UNNotificationSound.default()
        
        // 5秒後に通知
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "FiveSecond",
                                            content: content,
                                            trigger: trigger)
        
        // ローカル通知予約
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            EntityManager.shared.exchangePhotosDao.communicationWithDefaultUserCount { count in
                guard let count = count else {
                    return
                }
                
                switch count {
                case 0:
                    CommunicateDefaultUser.receive(photoPath: CommunicateDefaultUser.firstPhoto) { _, _ in }
                case 2:
                    CommunicateDefaultUser.receive(photoPath: CommunicateDefaultUser.secondPhoto) { _, _ in }
                case 4:
                    CommunicateDefaultUser.receive(photoPath: CommunicateDefaultUser.thirdPhoto) { _, _ in }
                case 6:
                    CommunicateDefaultUser.receive(photoPath: CommunicateDefaultUser.fourthPhoto) { _, _ in }
                default:
                    break
                }
            }
        }
    }
}
