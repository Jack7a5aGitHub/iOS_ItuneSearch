//
//  SendViewController.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/18.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import CoreLocation
import RSKImageCropper
import SVProgressHUD
import UIKit

enum SendStatus {
    case none
    case willBack
    case willSend
}

final class SendViewController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!

    private let initialImageAPI = InitialImageAPI()
    private let locationManager = LocationManager()
    private var clLocationManager: CLLocationManager?
    private var croped = false
    private var selectedImage: UIImage?
    private var selectedImageName: String?
    private var destinationID: String?

    var sendStatus = SendStatus.none

    // MARK: - Factory

    class func make(with image: UIImage, name: String, destinationID: String?) -> SendViewController {
        let vcName = SendViewController.className
        guard let sendVC = UIStoryboard.viewController(
            storyboardName: vcName, identifier: vcName) as? SendViewController else {
                fatalError("SendViewController is nil.")
        }
        sendVC.selectedImage = image
        sendVC.selectedImageName = name
        sendVC.destinationID = destinationID
        return sendVC
    }

    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        setupNavigationItem()
        imageView.image = selectedImage
        imageView.isHidden = true

        initialImageAPI.loadable = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if sendStatus != .none {
            imageView.isHidden = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        switch sendStatus {
        case .none:

            if croped {
                return
            }

            guard let selectedImage = self.selectedImage else {
                return
            }
            let imageCropVC = RSKImageCropViewController(image: selectedImage, cropMode: .custom)
            imageCropVC.dataSource = self
            imageCropVC.moveAndScaleLabel.text = "切り取り範囲を選択"
            imageCropVC.cancelButton.isHidden = true
            imageCropVC.chooseButton.setTitle("完了", for: .normal)
            imageCropVC.delegate = self
            self.present(imageCropVC, animated: true)

        case .willBack:
            return

        case .willSend:
            sendPhoto()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Actions
    @IBAction func didTapBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Private

    private func showSendModalViewController() {

        guard
            let image = selectedImage,
            let name = selectedImageName else {
                return
        }
        let modal = SendModalViewController.make(with: image, name: name)
        present(modal, animated: false, completion: nil)
    }

    private func sendPhoto() {
        SVProgressHUD.Piicto.show()
        // 位置情報を取得
        locationManager.delegate = self
        clLocationManager = CLLocationManager()
        clLocationManager?.desiredAccuracy = kCLLocationAccuracyKilometer
        clLocationManager?.delegate = locationManager
    }
}

extension SendViewController: InitialImageLoadable {

    func apiStatus(status: InitialImageAPIStatus) {

        switch status {

        case .loadingThen:
            print("loadingThen")

        case .loadedThen(response: let response):
            print("loadingThen")
            print(response)

        case .offlineThen:
            print("offlineThen")
            
        case .errorThen:
            print("errorThen")
        }
    }
}

extension SendViewController: LocationDelegate {

    func didUpdateLocations() {
        guard
            let uid = UserDefaults.standard.string(forKey: .uid),
            let selectedImageName = selectedImageName,
            let selectedImage = selectedImage,
            let imageData = UIImagePNGRepresentation(selectedImage) else {
                SVProgressHUD.dismiss()
                return
        }

        // ストレージにアップロード
        PiictoStorage.uploadImage(
            uid: uid,
            destinationID: destinationID,
            imageName: selectedImageName,
            imageData: imageData) { photoID in

                SVProgressHUD.dismiss()
                self.showSendModalViewController()
                guard
                    let photoID = photoID,
                    let latitude = UserDefaults.standard.double(forKey: .latitude),
                    let longitude = UserDefaults.standard.double(forKey: .longitude) else {
                        return
                }
                // TODO: - 緯度、経度を計算する
                // 初回送信APIを実行 (非初回送信の場合、photoIDはnil)
                self.initialImageAPI.post(photoID: photoID, latitude: latitude, longitude: longitude)
        }
    }
}

extension SendViewController: RSKImageCropViewControllerDelegate {

    /// 完了を押した後の処理
    func imageCropViewController(_ controller: RSKImageCropViewController,
                                 didCropImage croppedImage: UIImage,
                                 usingCropRect cropRect: CGRect,
                                 rotationAngle: CGFloat) {

        let maxCompression: CGFloat = 0.0
        let maxFileSize = 500
        var compression: CGFloat = 0.9

        guard
            let resizedImage = croppedImage.resize(size: CGSize(width: 1_125.0, height: 1_500.0)),
            let imageData = UIImageJPEGRepresentation(resizedImage, compression) else {
                return
        }

        var data = imageData
        let semaphore = DispatchSemaphore(value: 0)
        if data.count <= maxFileSize {
            semaphore.signal()
        }

        while data.count > maxFileSize && compression > maxCompression {
            compression -= 0.1
            data = UIImageJPEGRepresentation(resizedImage, compression) ?? Data()

            if data.count <= maxFileSize || compression <= maxCompression {
                semaphore.signal()
            }
        }

        semaphore.wait()
        selectedImage = UIImage(data: data)
        imageView.image = selectedImage
        croped = true
        dismiss(animated: true, completion: nil)
        showSendModalViewController()
    }

    /// キャンセルを押した時の処理
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension SendViewController: RSKImageCropViewControllerDataSource {

    func imageCropViewControllerCustomMaskRect(_ controller: RSKImageCropViewController) -> CGRect {

        var maskSize = CGSize.zero
        var width = CGFloat(0.0)
        var height = CGFloat(0.0)

        width = self.view.frame.width

        // 縦横比=4:3でトリミング
        height = self.view.frame.width * 1.25

        maskSize = CGSize(width: width, height: height)

        let viewWidth = controller.view.frame.width
        let viewHeight = controller.view.frame.height

        let maskRect: CGRect = CGRect(x: (viewWidth - maskSize.width) * 0.5,
                                      y: (viewHeight - maskSize.height) * 0.5,
                                      width: maskSize.width,
                                      height: maskSize.height)
        return maskRect
    }

    // トリミングする領域を描画
    func imageCropViewControllerCustomMaskPath(_ controller: RSKImageCropViewController) -> UIBezierPath {
        let rect = controller.maskRect

        let point1 = CGPoint(x: rect.minX, y: rect.maxY)
        let point2 = CGPoint(x: rect.maxX, y: rect.maxY)
        let point3 = CGPoint(x: rect.maxX, y: rect.minY)
        let point4 = CGPoint(x: rect.minX, y: rect.minY)

        let square = UIBezierPath()
        square.move(to: point1)
        square.addLine(to: point2)
        square.addLine(to: point3)
        square.addLine(to: point4)
        square.close()

        return square
    }

    func imageCropViewControllerCustomMovementRect(_ controller: RSKImageCropViewController) -> CGRect {
        return controller.maskRect
    }
}
