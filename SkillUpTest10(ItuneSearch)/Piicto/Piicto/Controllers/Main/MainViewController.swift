//
//  MainViewController.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/06.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import CoreLocation
import EAIntroView
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Photos
import SVProgressHUD
import UIKit
import UserNotifications
import FirebaseMessaging

/// メイン画面
final class MainViewController: UIViewController {
    
    @IBOutlet private weak var dustboxButton: UIButton!
    @IBOutlet private weak var facebookBotton: UIButton!
    @IBOutlet private weak var selectLibraryView: UIView!
    @IBOutlet private weak var talkingHistoryCollectionView: UICollectionView!
    @IBOutlet private weak var cameraButton: UIButton!
    
    
    
    private let alert = Alert()
    private let instagramAPI = InstagramAPI()
    private let locationManager = LocationManager()
    private let provider = TalkingHistoryProvider()
    private var accessToken: FBSDKAccessToken?
    private var clLocationManager: CLLocationManager?
    private var isScrollingToUp: Bool?
    private var scrollBeginingPoint: CGPoint?
    private var usersFacebookID = 0
    private var usersInstagramID = 0
    
    var userPhotos = [Any]()
    var exchangePhotoEntityArray = [ExchangePhotoEntity]()
    var lastSender = ""
    var partnerID = ""
    var index: Int?
    var ref: DatabaseReference?
    // MARK: - Factory
    
    class func make(exchangePhotoEntityArray: [ExchangePhotoEntity], index: Int) -> MainViewController {
        let vcName = MainViewController.className
        
        guard let mainVC = UIStoryboard.viewController(
            storyboardName: vcName, identifier: vcName) as? MainViewController else {
                fatalError("MainViewController is nil.")
        }
        mainVC.exchangePhotoEntityArray = exchangePhotoEntityArray
        mainVC.index = index
        
        print("mainVC.index: \(String(describing: mainVC.index))")
        return mainVC
    }
    
    private func setupDatabaseReference() {
        guard let uid = UserDefaults.standard.string(forKey: .uid) else {
            return
        }
        
        EntityManager.shared.exchangePhotos = []
        ref = EntityManager.shared.exchangePhotosDao.exchangePhotosReference.child(uid)
        ref?.observe(.value) { snapshot in
            
            let partners = snapshot.value as? [String: Any] ?? [:]
            for thePartner in partners {
                print("the partner uid: \(thePartner.key)")
                
                guard let photo = thePartner.value as? [String: Any] else {
                    continue
                }
                for photoInfo in photo {
                    print("photoInfo: \(photoInfo.value)")
                    print("photoInfo: \(photoInfo.key)")
                    let photo = Photo(photoID: photoInfo.key, visible: photoInfo.value as? Bool ?? false)
                    let exchangePhotoEntity = ExchangePhotoEntity(partnerID: thePartner.key, photo: photo)
                    EntityManager.shared.exchangePhotos.append(exchangePhotoEntity)
                }
            }
            EntityManager.shared.partnerIDArray = [String]()
            for exchangePhotos in EntityManager.shared.exchangePhotos {
                if !EntityManager.shared.partnerIDArray.contains(exchangePhotos.partnerID) {
                    EntityManager.shared.partnerIDArray.append(exchangePhotos.partnerID)
                }
            }
            let photos = EntityManager.shared.exchangePhotos
                .filter { $0.partnerID == EntityManager.shared.partnerIDArray[safe: self.index ?? 0] }
            let newPhotosArray = Array(photos.reversed())
            self.provider.set(exchangePhotoEntityArray: newPhotosArray)
            
            self.partnerID = EntityManager.shared.partnerIDArray[safe: self.index ?? 0] ?? ""
            
            guard let photoID = photos.first?.photo.photoID  else {
                return
            }
            
            EntityManager.shared.photosDao.photoByPhotoID(photoID: photoID) { photoEntity in
                self.lastSender = photoEntity.sender
            }
            self.provider.updateAllStatus(newType: .normal)
            self.talkingHistoryCollectionView.reloadData()
        }
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFlowLayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // カメラボタン・ゴミ箱ボタンはデフォルト非表示
        cameraButton.isHidden = true
        dustboxButton.isHidden = true
        
        
        if AppLaunch.isFirstTime() {
            showIntro(introPages: IntroPageProvider.pages())
            
        } else {
            setup()
            setupDatabaseReference()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideAll()
        ref?.removeAllObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.selectLibraryView.isHidden = true
    }
    
    // MARK: - Actions
    
    @IBAction func didTapDustboxButton(_ sender: UIButton) {
        print("didTapDustboxButton")
        
        let alert = UIAlertController(title: "", message: "写真を削除しますか?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            
            // 削除を実行する
            self.provider.cellItems.filter { $0.deleteCheckFlg }.forEach {
                var willDeleteEntity = $0.exchangePhotoEntity
                willDeleteEntity.photo.visible = false
                EntityManager.shared.exchangePhotosDao.update(exchangePhotoEntity: willDeleteEntity)
            }
            
            self.provider.cellItems.forEach { _ in
                self.provider.updateAllStatus(newType: .normal)
            }
            self.dustboxButton.isHidden = true
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.provider.cellItems.forEach {
                print("deleteCheckFlg: \($0.deleteCheckFlg)")
                self.provider.updateAllStatus(newType: .normal)
            }
            self.dustboxButton.isHidden = true
            self.talkingHistoryCollectionView.reloadData()
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func longPressCollectionView(_ sender: UILongPressGestureRecognizer) {
        print("collectionViewLongPressGestureRecognizer")
        let point = sender.location(in: self.talkingHistoryCollectionView)
        guard let indexPath = self.talkingHistoryCollectionView.indexPathForItem(at: point) else {
            return
        }
        if sender.state == .began {
            provider.updateStatus(newType: .trash, indexPath: indexPath)
            dustboxButton.isHidden = false
            cameraButton.isHidden = true
            talkingHistoryCollectionView.reloadData()
        }
    }
    
    @IBAction func didTapCamera(_ sender: UIButton) {
        
        if self.selectLibraryView.isHidden {
            // firebaseに登録があるか認証
            let instagramLoginStatus = UserDefaults.standard.bool(forKey: "instagramIsLogin")
            let facebookLoginStatus = Auth.auth().currentUser?.isAnonymous ?? false
            
            if instagramLoginStatus || !facebookLoginStatus {
                self.selectLibraryView.fadeInAnimation(type: .slow, completed: nil)
            } else {
                guard let usersUUID = UserDefaults.standard.string(forKey: .uid) else {
                    print("UUIDの登録がありません。")
                    return
                }
                getProfileData(uuid: usersUUID)
            }
        } else {
            let cameraVC = CameraViewController.make()
            navigationController?.pushViewController(cameraVC, animated: true)
        }
    }
    
    @IBAction func instagramLibrary(_ sender: UIButton) {
        
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
    
    @IBAction func facebookLibrary(_ sender: UIButton) {
        
        if FBSDKAccessToken.current() != nil {
            // facebookのアクセストークン作成ずみ
            // facebookライブラリにアクセス
            // TODO: 取得したuserDataのphotosにある画像URLをイメージとしてコレクションビューで表示する。
            getFacebookUserImages()
            
        } else {
            // facebook認証
            facebookAuth()
        }
    }
    
    @IBAction func userSelfLibrary(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerView = UIImagePickerController()
            pickerView.sourceType = .photoLibrary
            pickerView.delegate = self
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    // MARK: - Private
    
    private func setup() {
        
        registerNib()
        
        alert.tapAction = self
        instagramAPI.instagramAPIUserPhotosDelegate = self
        
        exchangePhotoEntityArray = EntityManager.shared.exchangePhotos
        provider.set(exchangePhotoEntityArray: exchangePhotoEntityArray)
        talkingHistoryCollectionView.dataSource = provider
        talkingHistoryCollectionView.delegate = self
        //        scrollToEnd()
        
        hideAll()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self,
                                                               action: #selector(longPressCollectionView(_:)))
        longPressRecognizer.allowableMovement = 10
        longPressRecognizer.minimumPressDuration = 0.5
        self.talkingHistoryCollectionView.addGestureRecognizer(longPressRecognizer)
    }
    
    private func registerNib() {
        let talkingHistoryCellNib = UINib(nibName: TalkingHistoryCell.nibName, bundle: nil)
        talkingHistoryCollectionView.register(talkingHistoryCellNib,
                                              forCellWithReuseIdentifier: TalkingHistoryCell.identifier)
    }
    
    private func scrollToEnd() {
        let indexPath = IndexPath(row: provider.cellItems.count - 1, section: 0)
        talkingHistoryCollectionView.scrollToItem(at: indexPath, at: .top, animated: false)
    }
    
    private func showIntro(introPages: [EAIntroPage]) {
        guard let introView = EAIntroView(frame: self.view.bounds, andPages: introPages) else {
            return
        }
        introView.skipButton.isHidden = true
        navigationController?.isNavigationBarHidden = true
        introView.delegate = self
        introView.show(in: self.view, animateDuration: 1.0)
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
                print("Now Get my FB ID: \(facebookID)")
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
            let key = UsersDao.usersReference.child(uid)
            let post = ["facebook_id": userInfomation.facebookID,
                        "name": userInfomation.name,
                        "profile_img_url": userInfomation.profileImgURL]
                as [String : Any]
            key.updateChildValues(post)
            //  UsersDao.update(userEntity: userInfomation)
        })
    }
    
    private func getFacebookUserImages() {
        // TODO: facebookからユーザーの写真情報を取得する
        print("ユーザーのフォトライブラリを取得")
        
        // TODO: 一時的にフォトライブラリ画面に移動（画像のpathの配列を渡す）
        let libraryVC = LibraryViewController.make(photoList: [])
        self.navigationController?.pushViewController(libraryVC, animated: true)
    }
    
    private func getProfileData(uuid: String) {
        
        let conditionRef = UsersDao.usersReference.child(uuid)
        
        conditionRef.observeSingleEvent(of: .value) { (snapshot) in
            
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
            
        } else {
            // ログイン済み
            self.selectLibraryView.fadeInAnimation(type: .slow, completed: nil)
        }
    }
}

// MARK: - AlertDelegate
extension MainViewController: AlertDelegate {
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

// MARK: - InstagramAPIUserPhotosDelegate
extension MainViewController: InstagramAPIUserPhotosDelegate {
    func successful(photos: [URL]) {
        let libraryVC = LibraryViewController.make(photoList: photos)
        self.navigationController?.pushViewController(libraryVC, animated: true)
    }
    
    func failed() {
        // TODO: エラーハンドリング用のアラート表示
    }
}

// MARK: - UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard
            let selectedCell = collectionView.cellForItem(at: indexPath) as? TalkingHistoryCell,
            let cellType = selectedCell.cellType else {
                return
        }
        hideProfileImages(notHideAt: indexPath)
        
        if case CellType.normal = cellType {
            selectedCell.userButton(isHidden: false)
            selectedCell.likeButton(isHidden: false)
            provider.updateStatus(newType: .selected, indexPath: indexPath)
            
            guard let uid = UserDefaults.standard.string(forKey: .uid) else {
                return
            }
            if lastSender == uid {
                cameraButton.isHidden = true
            } else {
                cameraButton.isHidden = false
            }
        } else {
            selectedCell.userButton(isHidden: true)
            selectedCell.likeButton(isHidden: true)
            provider.updateStatus(newType: .normal, indexPath: indexPath)
            cameraButton.isHidden = true
        }
        scrollToCell(cell: selectedCell)
        talkingHistoryCollectionView.reloadData()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideAll()
        scrollBeginingPoint = scrollView.contentOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hideAll()
        guard let scrollBeginingPoint = scrollBeginingPoint else {
            return
        }
        let currentPoint = scrollView.contentOffset
        if scrollBeginingPoint.y < currentPoint.y {
            print("下へスクロール")
            isScrollingToUp = false
        } else {
            print("上へスクロール")
            isScrollingToUp = true
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        didEndScrollingOrDragging()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didEndScrollingOrDragging()
    }
    
    /// 指定IndexPath以外のセルのイメージをnilクリアする
    private func hideProfileImages(notHideAt indexPath: IndexPath) {
        for row in 0 ..< provider.cellItems.count where row != indexPath.row {
            guard let cell = talkingHistoryCollectionView.cellForItem(at: IndexPath(row: row, section: 0))
                as? TalkingHistoryCell else {
                    continue
            }
            cell.userButton(isHidden: true)
            cell.likeButton(isHidden: true)
            cell.set(nextProfileImage: nil)
            cell.set(previousProfileImage: nil)
        }
    }
    
    private func hideAll() {
        
        let dataCount = provider.cellItems.count
        for row in 0 ..< dataCount {
            guard let cell = talkingHistoryCollectionView.cellForItem(at: IndexPath(row: row, section: 0))
                as? TalkingHistoryCell else {
                    continue
            }
            cell.userButton(isHidden: true)
            cell.likeButton(isHidden: true)
            cell.set(nextProfileImage: nil)
            cell.set(previousProfileImage: nil)
        }
        cameraButton.isHidden = true
    }
    
    /// スクロールまたはドラッグが終了した
    private func didEndScrollingOrDragging() {
        guard let isScrollingToUp = isScrollingToUp else {
            return
        }
        let perfectVisibleCells = talkingHistoryCollectionView.visibleCells.filter {
            talkingHistoryCollectionView.bounds.contains($0.frame)
        }
        // 完全に表示されているセルが無い場合一番高さが大きいセルを中心にする
        if perfectVisibleCells.isEmpty {
            scrollWhenNotExistsPerfectVisibleCell(isScrollingToUp: isScrollingToUp)
            return
        }
        scrollWhenExistsPerfectVisibleCell(isScrollingToUp: isScrollingToUp, perfectVisibleCells: perfectVisibleCells)
    }
    
    /// 完全に表示されているセルが無い場合のスクロール位置調整
    private func scrollWhenNotExistsPerfectVisibleCell(isScrollingToUp: Bool) {
        if isScrollingToUp {
            guard let theCenterCell = talkingHistoryCollectionView.visibleCells.sorted(by: { cell, otherCell -> Bool in
                cell.bounds.height >= otherCell.bounds.height
            }).first else {
                return
            }
            scrollToCell(cell: theCenterCell)
            return
        }
        guard let theCenterCell = talkingHistoryCollectionView.visibleCells.sorted(by: { cell, otherCell -> Bool in
            cell.bounds.height < otherCell.bounds.height
        }).first else {
            return
        }
        scrollToCell(cell: theCenterCell)
    }
    
    /// 完全に表示されているセルが有る場合
    private func scrollWhenExistsPerfectVisibleCell(isScrollingToUp: Bool,
                                                    perfectVisibleCells: [UICollectionViewCell]) {
        if isScrollingToUp {
            guard let perfectVisibleFirstCell = perfectVisibleCells.first else {
                return
            }
            scrollToCell(cell: perfectVisibleFirstCell)
            return
        }
        guard let perfectVisibleLastCell = perfectVisibleCells.last else {
            return
        }
        scrollToCell(cell: perfectVisibleLastCell)
    }
    
    /// 指定セルが中心に来るようスクロールする
    private func scrollToCell(cell: UICollectionViewCell) {
        guard let indexPath = talkingHistoryCollectionView.indexPath(for: cell) else {
            return
        }
        hideProfileImages(notHideAt: indexPath)
        talkingHistoryCollectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }
    private func pushNotificationAuth(){
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .notDetermined {
                
                let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { (granted, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    
                    if granted {
                        print("granted!!")
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                        return
                    }
                    print("PUSH通知拒否")
                })
                DispatchQueue.main.async {
                    
                    UNUserNotificationCenter.current().delegate = self
                }
                Messaging.messaging().delegate = self
                let token = Messaging.messaging().fcmToken
                print("FCM token: \(token ?? "")")
                print("I would like to ask your permission")
            }
        }
    }
}

extension MainViewController {
    
    func setupFlowLayout() {
        talkingHistoryCollectionView.frame.size = CGSize(width: view.frame.width,
                                                         height: talkingHistoryCollectionView.frame.height)
        let flowLayout = TalkingHistoryCollectionViewFlowLayout()
        let collectionViewWidth = talkingHistoryCollectionView.frame.size.width
        flowLayout.itemSize = CGSize(width: collectionViewWidth,
                                     height: collectionViewWidth * 4 / 3)
        flowLayout.minimumLineSpacing = 0
        talkingHistoryCollectionView.collectionViewLayout = flowLayout
    }
}

// MARK: - EAIntroDelegate
extension MainViewController: EAIntroDelegate {
    
    func introDidFinish(_ introView: EAIntroView, wasSkipped: Bool) {
        navigationController?.isNavigationBarHidden = false
        SVProgressHUD.Piicto.show()
        PiictoAuth.signInAnonymously()
        locationManager.delegate = self
        clLocationManager = CLLocationManager()
        clLocationManager?.delegate = locationManager
        clLocationManager?.desiredAccuracy = kCLLocationAccuracyKilometer
        pushNotificationAuth()
    }
}

// MARK: - LocationDelegate
extension MainViewController: LocationDelegate {
    
    func didUpdateLocations() {
        SVProgressHUD.dismiss()
        
        EntityManager.shared.exchangePhotosDao.communicationWithDefaultUserOrNot(
            completionBlock: { hasAlreadyCommunicated in
                if !hasAlreadyCommunicated {
                    // ここでデフォルトユーザから写真が来たことにする。
                    CommunicateDefaultUser.receive(photoPath: CommunicateDefaultUser.firstPhoto) { _, _ in
                        self.setupDatabaseReference()
                        AppLaunch.completedFirstLaunch()
                    }
                }
        })
    }
}

extension MainViewController: UNUserNotificationCenterDelegate {
    
    // アプリがフォアグランドの時に通知を受け取ると呼ばれる
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Now Fourground. Message ID: \(String(describing: userInfo["gcm.message_id"]))")
        
        // Print full message.
        print("%@", userInfo)
        
        // サウンドとアラート
        completionHandler([.sound, .alert])
    }
}

extension MainViewController: MessagingDelegate {
    // Receive data message on iOS 10 devices.
    func application(received remoteMessage: MessagingRemoteMessage) {
        print("%@", remoteMessage.appData)
    }
}
