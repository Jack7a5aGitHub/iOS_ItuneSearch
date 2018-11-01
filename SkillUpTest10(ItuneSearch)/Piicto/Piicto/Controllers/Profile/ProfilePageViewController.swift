//
//  ProfilePageViewController.swift
//  Piicto
//
//  Created by kawaharadai on 2018/01/27.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import Firebase
import Kingfisher
import UIKit

// TODO: 現状、画面下部の会社情報に飛ぶURLはコーポレートページ内のURLを指定、後日遷移先URLを頂く予定
private enum AccessInfomation: String {
    case teamOfService = "https://www.yudo.jp"
    case privacy = "https://www.yudo.jp/about"
    case others = "https://www.yudo.jp/contact"
}

final class ProfilePageViewController: UIViewController {
    
    @IBOutlet private weak var userProfileImage: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var totalHeartCountLabel: UILabel!
    @IBOutlet private weak var profileTextView: UITextView!
    
    var partnerId: String?
    var testExchangePhotos = ["FuSvOZgnU3OtUNufuJiiQAU2KHq1", "Yb7mnvVnYrZ3pBqvDiyBjSXzjsz2", "FuSvOZgnU3OtUNufuJiiQAU2KHq1"]
    
    // MARK: - Factory
    
    class func make(partnerId: String?) -> ProfilePageViewController {
        let vcName = ProfilePageViewController.className
        guard let profileVC = UIStoryboard.viewController(
            storyboardName: vcName, identifier: vcName) as? ProfilePageViewController else {
                fatalError("ProfilePageViewController is nil.")
        }
        profileVC.partnerId = partnerId
        return profileVC
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if partnerId != nil {
            // フォロワーユーザーのプロフィールページ
        } else {
            // ユーザー自身のプロフィールページ
            loadProfileData(userSelf: true)
            loadProfileData(userSelf: false)
            
            addLayer(view: self.userProfileImage,
                     corner: self.userProfileImage.frame.width / 2,
                     borderColor: .lightGray,
                     borderWidth: 0)
            
            addLayer(view: self.profileTextView,
                     corner: 10,
                     borderColor: .lightGray,
                     borderWidth: 2)
        }
    }
    
    // MARK: - Action
    
    @IBAction func back(_ sender: UIButton) {
        // TODO: 殿が画面から来てもrootViewControllerに戻るため、前のViewControllerが残ってしまう可能性がある
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func background(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func teamOfService(_ sender: UIButton) {
        let infoVC = InfomationPageViewController.make(accessURL: AccessInfomation.teamOfService.rawValue)
        self.navigationController?.pushViewController(infoVC, animated: true)
    }
    
    @IBAction func privacy(_ sender: UIButton) {
        let infoVC = InfomationPageViewController.make(accessURL: AccessInfomation.privacy.rawValue)
        self.navigationController?.pushViewController(infoVC, animated: true)
    }
    
    @IBAction func others(_ sender: UIButton) {
        let infoVC = InfomationPageViewController.make(accessURL: AccessInfomation.others.rawValue)
        self.navigationController?.pushViewController(infoVC, animated: true)
    }
    
    // MARK: - Private
    
    private func setup() {
        
        setupNavigationItem()
        
        self.profileTextView.delegate = self
        
        if partnerId != nil {
            // フォロワーユーザーのプロフィールページ
        } else {
            // ユーザー自身のプロフィールページ
            guard let saveProfileText = UserDefaults.standard.string(forKey: "userProfileText") else {
                return
            }
            self.profileTextView.text = saveProfileText
        }
    }
    
    private func loadProfileData(userSelf: Bool) {
        
        if userSelf {
            guard let usersUUID = UserDefaults.standard.string(forKey: .uid) else {
                return
            }
            seachProfileData(uuid: usersUUID, userSelf: true, viewTag: 0)
        } else {
            for index in 0..<testExchangePhotos.count {
                if testExchangePhotos.count > index && index < 15 {
                    // フォロワー分のViewをインスタンス化してプロフィールを表示
                    seachProfileData(uuid: testExchangePhotos[index], userSelf: false, viewTag: index + 100)
                }
            }
        }
    }
    
    private func seachProfileData(uuid: String, userSelf: Bool, viewTag: Int) {
        
        let conditionRef = UsersDao.usersReference.child(uuid)
        
        conditionRef.observeSingleEvent(of: .value) { (snapshot) in
            
            guard  let dataList = snapshot.value as? [String: Any] else {
                return
            }
            
            // 自分またはフォロワーの情報を取得
            if userSelf {
                self.setUserInfomation(userDataList: dataList)
            } else {
                self.setFollowerInfomation(followerDataList: dataList, viewTag: viewTag)
            }
            return
        }
    }
    
    private func setUserInfomation(userDataList: [String: Any]) {
        
        for userData in userDataList {
            
            if let userInfo = userData.value as? String {
                
                switch userData.key {
                    
                case UserEntityKey.name:
                    self.userNameLabel.text = userInfo
                    
                case UserEntityKey.profileImgURL:
                    if userInfo.isEmpty {
                        self.userProfileImage.image = #imageLiteral(resourceName: "setting_user_icon")
                    } else {
                        guard let url = URL(string: userInfo) else {
                            self.userProfileImage.image = #imageLiteral(resourceName: "setting_user_icon")
                            return
                        }
                        self.userProfileImage.kf.setImage(with: url)
                    }
                default:
                    break
                }
            } else {
                if let userInfo = userData.value as? Int {
                    
                    switch userData.key {
                        
                    case UserEntityKey.totalHeart:
                        self.totalHeartCountLabel.text = String(userInfo)
                        
                    default:
                        break
                    }
                }
            }
        }
    }
    
    private func setFollowerInfomation(followerDataList: [String: Any], viewTag: Int) {
        
        for followerData in followerDataList {
            
            if let followerInfo = followerData.value as? String {
                
                guard let followerImageView = setFollowerImageView(tag: viewTag) else {
                    return
                }
                
                switch followerData.key {
                    
                case UserEntityKey.profileImgURL:
                    if followerInfo.isEmpty {
                        followerImageView.image = #imageLiteral(resourceName: "setting_user_icon")
                        followerImageView.backgroundColor = UIColor.red
                    } else {
                        guard let url = URL(string: followerInfo) else {
                            followerImageView.image = #imageLiteral(resourceName: "setting_user_icon")
                            followerImageView.backgroundColor = UIColor.blue
                            return
                        }
                        followerImageView.kf.setImage(with: url)
                    }
                default:
                    break
                }
            }
        }
    }
    
    private func setFollowerImageView(tag: Int) -> UIImageView? {
        
        guard let followerImageView = self.view.viewWithTag(tag) as? UIImageView else {
            return nil
        }
        
        addLayer(view: followerImageView,
                 corner: followerImageView.frame.width / 2,
                 borderColor: .black,
                 borderWidth: 0)
        
        followerImageView.isHidden = false
        
        return followerImageView
    }
    
    private func addLayer(view: UIView,
                          corner: CGFloat,
                          borderColor: UIColor,
                          borderWidth: CGFloat) {
        
        view.layer.masksToBounds = true
        view.layer.cornerRadius = corner
        view.layer.borderColor = borderColor.cgColor
        view.layer.borderWidth = borderWidth
    }
}

extension ProfilePageViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        UserDefaults.standard.set(textView.text, forKey: "userProfileText")
    }
}
