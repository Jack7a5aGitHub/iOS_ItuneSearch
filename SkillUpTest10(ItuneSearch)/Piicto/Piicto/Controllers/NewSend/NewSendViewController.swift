//
//  NewSendViewController.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/28.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth
import Photos
import UIKit

final class NewSendViewController: UIViewController {
    
    private let instagramAPI = InstagramAPI()
    private let alert = Alert()
    private var usersFacebookID = 0
    private var usersInstagramID = 0
    private var FCMToken = ""
    private var imageName = ""
    
    // MARK: - Factory
    
    class func make() -> NewSendViewController {
        let vcName = NewSendViewController.className
        guard let newSendVC = UIStoryboard.viewController(
            storyboardName: vcName, identifier: vcName) as? NewSendViewController else {
                fatalError("NewSendViewController is nil.")
        }
        return newSendVC
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Actions
    
    @IBAction func didTapInstagramButton(_ sender: UIButton) {
        let instagramAuthStatus = UserDefaults.standard.bool(forKey: "instagramIsLogin")
        
        if instagramAuthStatus {
            guard let accessToken = UserDefaults.standard.string(forKey: "instagramAccessToken") else {
                instagramAuth()
                return
            }
            instagramAPI.userPhotosRequest(accssToken: accessToken, endPoint: "/users/self/media/recent")
            
        } else {
            instagramAuth()
        }
    }
    
    @IBAction func didTapFacebookButton(_ sender: UIButton) {
        
        if FBSDKAccessToken.current() != nil {
            print("API通信で画像を取得")
        } else {
            // facebook認証
            facebookAuth()
        }
    }
    
    @IBAction func didTapLibraryButton(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerView = UIImagePickerController()
            pickerView.sourceType = .photoLibrary
            pickerView.delegate = self
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapCameraButton(_ sender: UIButton) {
        // firebaseに登録があるか認証
        let instagramLoginStatus = UserDefaults.standard.bool(forKey: "instagramIsLogin")
        let facebookLoginStatus = Auth.auth().currentUser?.isAnonymous ?? false
        
        if instagramLoginStatus || !facebookLoginStatus {
            let cameraVC = CameraViewController.make()
            navigationController?.pushViewController(cameraVC, animated: true)
        } else {
            guard let usersUUID = UserDefaults.standard.string(forKey: .uid) else {
                print("UUIDの登録がありません。")
                return
            }
            getProfileData(uuid: usersUUID)
        }
    }
    
    // MARK: - Private
    
    private func setup() {
        alert.tapAction = self
        instagramAPI.instagramAPIUserPhotosDelegate = self
    }
    
    // TODO: 以下、Mainページと同様のメソッドを使っています。
    private func getProfileData(uuid: String) {
        
        let conditionRef = UsersDao.usersReference.child(uuid)
        
        conditionRef.observeSingleEvent(of: .value) { snapshot in
            
            guard  let dataList = snapshot.value as? [String: Any] else {
                return
            }
            
            for userData in dataList {
                
                if let userInfo = userData.value as? Int {
                    
                    switch userData.key {
                        
                    case UserEntityKey.facebookID:
                        self.usersFacebookID = userInfo
                        
                        
                    case UserEntityKey.instagramID:
                        self.usersInstagramID = userInfo
                        
                    default:
                        break
                    }
                }
            }
            self.checkUserAuth()
        }
    }
    
    private func checkUserAuth() {
        
        if self.usersFacebookID == 0 && self.usersInstagramID == 0 {
            // 未ログイン
            let authAlert = alert.authAlert(title: "ユーザー認証が必要です。",
                                            message: "下記から選択してください。",
                                            instagramAuthTitle: "instagram認証",
                                            facebookAuthTitle: "facebook認証")
            
            self.present(authAlert, animated: true, completion: nil)
            
        }
    }
    
    private func getFacebookUserData() {
        
        guard FBSDKAccessToken.current() != nil else {
            print("facebookのアクセストークンが存在しない")
            facebookAuth()
            return
        }
        
        let request = FBSDKGraphRequest(graphPath: "me/",
                                        parameters: ["fields": "id, name, picture"])
        
        request?.start(completionHandler: { _, result, error in
            
            if error != nil {
                print("facebook情報の取得に失敗")
                return
            }
            
            guard let graph = result as? [String: Any] else {
                return
            }
            
            var userInfomation = UserEntity()
            
            guard let uid = UserDefaults.standard.string(forKey:
                .uid) else {
                    print("firebaseへのユーザー情報のアップデートに失敗")
                    return
            }
            userInfomation.userID = uid
            
            if let id = graph["id"] as? String {
                guard let facebookID = Int(id) else {
                    return
                }
                userInfomation.facebookID = facebookID
                print("Now Testing in NewSend \(facebookID)")
            }
            
            if let name = graph["name"] as? String {
                userInfomation.name = name
            }
            
            if let picture = graph["picture"] as? [String: Any] {
                if let data = picture["data"] as? [String: Any] {
                    if let source = data["url"] as? String {
                        userInfomation.profileImgURL = source
                    }
                }
            }
            
            // facebook情報をfirebaseに上書き
            
            let key = UsersDao.usersReference.child(uid)
            let post = ["facebook_id": userInfomation.facebookID,
                        "name": userInfomation.name,
                        "profile_img_url": userInfomation.profileImgURL]
                as [String : Any]
            key.updateChildValues(post)
            // UsersDao.update(userEntity: userInfomation)
        })
    }
}

extension NewSendViewController: UIImagePickerControllerDelegate {
    
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
                    self.imageName = imageName
                    let sendVC = SendViewController.make(with: image,
                                                         name: imageName,
                                                         destinationID: nil)
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

extension NewSendViewController: UINavigationControllerDelegate {}

extension NewSendViewController: AlertDelegate {
    
    func instagramAuth() {
        let instagramAuthVC = InstagramAuthViewController.make()
        present(instagramAuthVC, animated: true, completion: nil)
    }
    
    func facebookAuth() {
        let loginManeger = FBSDKLoginManager()
        
        loginManeger.logIn(withReadPermissions: ["public_profile", "email", "user_photos"],
                           from: self) { result, error in
                            
                            guard let authResult = result else {
                                print("facebook login Process error")
                                return
                            }
                            
                            if error != nil {
                                print("facebook login Process error")
                            } else if authResult.isCancelled {
                                print("facebook login Cancelled")
                            } else {
                                guard let usersAccessTokenString = result?.token.tokenString else {
                                    print("noting usersAccessToken")
                                    return
                                }
                                
                                // facebook認証にてfirebaseにログイン（別途認証結果を保存する？）
                                let credential = FacebookAuthProvider.credential(withAccessToken: usersAccessTokenString)
                                
                                Auth.auth().signIn(with: credential) { fireUser, fireError in
                                    if fireError != nil {
                                        print("firebase auth error")
                                        return
                                    }
                                    // ログイン完了後の処理
                                    self.getFacebookUserData()
                                    
                                    // アクセストークンを使ってgraphAPIからユーザープロフィールをゲットする
                                    print("firebaseへのfacebookによる認証登録完了")
                                }
                            }
        }
    }
}

extension NewSendViewController: InstagramAPIUserPhotosDelegate {
    func successful(photos: [URL]) {
        let libraryVC = LibraryViewController.make(photoList: photos)
        self.navigationController?.pushViewController(libraryVC, animated: true)
    }
    
    func failed() {
        // TODO: エラーハンドリング用のアラート表示
    }
}
