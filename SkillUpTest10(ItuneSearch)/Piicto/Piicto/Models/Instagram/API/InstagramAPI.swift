//
//  InstagramAPI.swift
//  Piicto
//
//  Created by kawaharadai on 2018/02/01.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import Alamofire
import ObjectMapper

protocol InstagramAPIAuthDelegate: class {
    func finishedAuth()
}

protocol InstagramAPIUserPhotosDelegate: class {
    func successful(photos: [URL])
    func failed()
}

class InstagramAPI {
    
    private let baseURL = "https://api.instagram.com/v1"
    
    weak var instagramAPIDelegate: InstagramAPIAuthDelegate?
    weak var instagramAPIUserPhotosDelegate: InstagramAPIUserPhotosDelegate?
    
    func userDataRequest(accssToken: String, endPoint: String) {
        // 通信状況判定
        if !APIClient.isReachable() {
            return
        }
        
        let requestURLString = baseURL + endPoint + "/?access_token=" + accssToken
        
        guard let requestURL = URL(string: requestURLString) else {
            print("URLが正しくありません。")
            return
        }
        
        Alamofire.request(requestURL).responseData { [weak self] response in
            switch response.result {
                
            case .success(let jsonData):
                
                guard let usersUUID = UserDefaults.standard.string(forKey: .uid) else {
                    print("ユーザー登録自体がない")
                    return
                }
                
                guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                    print("jsonデータの読み取りに失敗")
                    return
                }
                
                let mapJsonString = Mapper<InstagramUserDataResponse>().map(JSONString: jsonString)
                
                var userInfo = UserEntity()
                userInfo.userID = usersUUID
                
                if let instagramUserName = mapJsonString?.userName {
                    userInfo.name = instagramUserName
                }
                
                if let instagramUserProfileImageURL = mapJsonString?.profilePicture {
                    userInfo.profileImgURL = instagramUserProfileImageURL
                }
                
                // instagramIDの登録がない場合は、認証済みとしない
                if
                    let userID = mapJsonString?.userID,
                    let instagramID = Int(userID) {
                    userInfo.instagramID = instagramID
                    UserDefaults.standard.set(true, forKey: "instagramIsLogin")
                }
                
                // 取得したユーザー情報をfirebaseに登録
                UsersDao.update(userEntity: userInfo)
                
                self?.instagramAPIDelegate?.finishedAuth()
                
            case .failure(let error):
                print("error_code: \((error as NSError).code)")
                print("error_description: \((error as NSError).description)")
            }
        }
    }
    
    func userPhotosRequest(accssToken: String, endPoint: String) {
        // 通信状況判定
        if !APIClient.isReachable() {
            return
        }
        
        let requestURLString = baseURL + endPoint + "/?access_token=" + accssToken
        var photos = [URL]()
        
        guard let requestURL = URL(string: requestURLString) else {
            print("URLが正しくありません。")
            return
        }
        
        Alamofire.request(requestURL).responseData { [weak self] response in
            switch response.result {
                
            case .success(let jsonData):
                
                guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                    print("jsonデータの読み取りに失敗")
                    return
                }
                
                let mapJsonString = Mapper<InstagramUserPhotosResponse>().map(JSONString: jsonString)
                
                guard let userMediaData = mapJsonString?.userPhotoData else {
                    print("ユーザーのメディアデータがありません。")
                    return
                }
                
                for mediaData in userMediaData {
                    if let imageURL = URL(string: mediaData.imageURLString) {
                        photos.append(imageURL)
                    }
                }
                
                self?.instagramAPIUserPhotosDelegate?.successful(photos: photos)
                
            case .failure(let error):
                print("error_code: \((error as NSError).code)")
                print("error_description: \((error as NSError).description)")
                self?.instagramAPIUserPhotosDelegate?.failed()
            }
        }
    }
}
