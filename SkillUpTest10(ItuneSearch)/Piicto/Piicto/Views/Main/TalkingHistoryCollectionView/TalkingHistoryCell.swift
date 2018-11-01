//
//  TalkingHistoryCell.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/07.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import FirebaseStorage
import Kingfisher
import UIKit

enum CellType {
    case normal
    case selected
    case trash
}

protocol DeleteCheckDelegate: class {
    func didChangeCheckFlg(newValue: Bool, indexPath: IndexPath)
}

/// 履歴セル
final class TalkingHistoryCell: UICollectionViewCell {

    static var identifier: String {
        return self.className
    }

    static var nibName: String {
        return self.className
    }

    @IBOutlet private weak var deleteCheckButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var leftImageView: UIImageView!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var rightImageView: UIImageView!
    @IBOutlet private weak var sourceAddressLabel: UILabel!
    @IBOutlet private weak var userButton: UIButton!

    weak var deleteCheckDelegate: DeleteCheckDelegate?
    var isEnabledEdittingLike = true
    var reverseGeocoding = ReverseGeocoding()
    
    var cellType: CellType? {
        didSet {
            guard let cellType = cellType else {
                return
            }

            var willDelete = false
            var iconHidden = true
            //var leftIconHidden = true
            //var rightIconHidden = true
            switch cellType {

            case .normal:
                break

            case .selected:
         
            iconHidden = true

            case .trash:
                willDelete = true
            }
            self.deleteCheckButton.isHidden = !willDelete
            guard
                let photoID = exchangePhotoEntity?.photo.photoID,
                let uid = UserDefaults.standard.string(forKey: .uid) else {
                    return
            }
            EntityManager.shared.photosDao.photoByPhotoID(photoID: photoID) { photoEntity in
                if photoEntity.sender == uid {
                    self.deleteCheckButton.isHidden = true
                }
            }

            self.vibrated(vibrated: willDelete)
            userButton.isHidden = iconHidden
            leftImageView.image = #imageLiteral(resourceName: "user_icon")
            leftImageView.isHidden = iconHidden
            rightImageView.image = #imageLiteral(resourceName: "user_icon")
            rightImageView.isHidden = iconHidden
        }
    }

    var exchangePhotoEntity: ExchangePhotoEntity? {
        didSet {
            guard
                let partnerID = exchangePhotoEntity?.partnerID,
                let photoID = exchangePhotoEntity?.photo.photoID,
                let visible = exchangePhotoEntity?.photo.visible else {
                return
            }

            EntityManager.shared.photosDao.photoByPhotoID(photoID: photoID) { photoEntity in

                // いいね!ボタンは、相手の写真の場合のみ表示する
                self.likeButton.isSelected = photoEntity.heart
                if photoEntity.sender == partnerID {
                    self.isEnabledEdittingLike = true
                } else {
                    self.isEnabledEdittingLike = false
                }

                // 送信ユーザ情報
                UsersDao.userInfo(userID: photoEntity.sender, completionBlock: { userEntity in
                    self.userButton.setTitle(userEntity.name, for: .normal)
                    self.userButton.titleLabel?.adjustsFontSizeToFitWidth = true
                    print(userEntity.profileImgURL)
                    self.userButton.imageView?.kf.setImage(with: URL(string: userEntity.profileImgURL))
                })

                // ラベル
                self.reverseGeocoding.delegate = self
                self.reverseGeocoding.placemark(latitude: photoEntity.latitude, longitude: photoEntity.longitude)

                // イメージ
                PiictoStorage.downloadURL(
                    uid: photoEntity.sender,
                    imageName: photoEntity.photoPath,
                    completionBlock: { url in
                        
                        guard let url = url else {
                            print("Image url is nil.")
                            return
                        }
                        self.imageView.kf.setImage(with: url)
                })
            }
            self.isHidden = !visible
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        deleteCheckButton.isHidden = true
        userButton.isHidden = true
        likeButton.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        rightImageView.layer.cornerRadius = rightImageView.frame.size.width / 2
        leftImageView.layer.cornerRadius = leftImageView.frame.size.width / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        deleteCheckButton.isSelected = false
        deleteCheckButton.isHidden = true
        userButton.isHidden = true
        likeButton.isHidden = true
        rightImageView.image = nil
        leftImageView.image = nil
    }
    
    // MARK: - Actions
    @IBAction func didTapLike(_ sender: UIButton) {
        print(#function)
        guard let photoID = exchangePhotoEntity?.photo.photoID else {
            return
        }
        sender.isSelected = !sender.isSelected
        PhotosDao.updateHeart(photoID: photoID, newValue: sender.isSelected)
    }
    
    @IBAction func didTapUser(_ sender: UIButton) {
        print(#function)
    }

    @IBAction func didTapDeleteCheck(_ sender: UIButton) {
        print("didTapDeleteCheck")

        if
            let collectionView = self.superview as? UICollectionView,
            let indexPath = collectionView.indexPath(for: self) {
            sender.isSelected = !sender.isSelected
            deleteCheckDelegate?.didChangeCheckFlg(newValue: sender.isSelected, indexPath: indexPath)
        }
    }

    // MARK: - set when selected the cell.
    func set(nextProfileImage: UIImage?) {
        guard let nextProfileImage = nextProfileImage else {
            rightImageView.image = nil
            rightImageView.isHidden = true
            return
        }
        rightImageView.image = nextProfileImage
        rightImageView.isHidden = false
    }

    func set(previousProfileImage: UIImage?) {
        guard let previousProfileImage = previousProfileImage else {
            leftImageView.image = nil
            leftImageView.isHidden = true
            return
        }
        leftImageView.image = previousProfileImage
        leftImageView.isHidden = false
    }
    
    func userButton(isHidden: Bool) {
        userButton.isHidden = isHidden
    }
    
    func likeButton(isHidden: Bool) {
        likeButton.isHidden = isHidden
    }
    
    func deleteCheckButton(isHidden: Bool) {
        deleteCheckButton.isHidden = isHidden
    }

    func deleteCheckButton(isSelected: Bool) {
        deleteCheckButton.isSelected = isSelected
    }
}

extension TalkingHistoryCell: ReverseGeocodingDelegate {
    func didReceiveReverseGeocodeResponse(locality: String, country: String) {
        sourceAddressLabel.text = "\(locality) \(country)"
    }
}
