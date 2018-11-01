//
//  TalkingHistoryProvider.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/07.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import UIKit

struct CellItem {
    var cellType = CellType.normal
    var deleteCheckFlg = false
    var exchangePhotoEntity = ExchangePhotoEntity()
}

final class TalkingHistoryProvider: NSObject {

    var cellItems = [CellItem]()

    func set(exchangePhotoEntityArray: [ExchangePhotoEntity]) {

        self.cellItems = []

        for exchangePhotoEntity in exchangePhotoEntityArray where exchangePhotoEntity.photo.visible {
            self.cellItems.append(CellItem(cellType: .normal,
                                           deleteCheckFlg: false,
                                           exchangePhotoEntity: exchangePhotoEntity))
        }
    }

    /// セルタイプを更新する
    func updateStatus(newType: CellType, indexPath: IndexPath) {
        guard self.cellItems[safe: indexPath.row] != nil else {
            return
        }

        switch newType {
        case .normal:
            for index in 0 ..< self.cellItems.count {
                self.cellItems[index].cellType = .normal
            }
        case .selected:
            for index in 0 ..< self.cellItems.count {
                self.cellItems[index].cellType = .normal
            }
            self.cellItems[indexPath.row].cellType = .selected

        case .trash:
            for index in 0 ..< self.cellItems.count {
                self.cellItems[index].cellType = .trash
            }

        }
    }

    func updateAllStatus(newType: CellType) {

        switch newType {
        case .normal:
            for index in 0 ..< self.cellItems.count {
                self.cellItems[index].cellType = .normal
                self.cellItems[index].deleteCheckFlg = false
            }

        case .trash:
            for index in 0 ..< self.cellItems.count {
                self.cellItems[index].cellType = .trash
            }
        default:
            break
        }
    }
}

extension TalkingHistoryProvider: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellItems.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TalkingHistoryCell.identifier,
            for: indexPath) as? TalkingHistoryCell else {
                fatalError("TalkingHistoryCell is nil.")
        }

        cell.deleteCheckDelegate = self
        cell.exchangePhotoEntity = cellItems[safe: indexPath.row]?.exchangePhotoEntity
        cell.cellType = cellItems[safe: indexPath.row]?.cellType
        cell.deleteCheckButton(isHidden: cellItems[safe: indexPath.row]?.cellType != .trash)
        cell.deleteCheckButton(isSelected: cellItems[safe: indexPath.row]?.deleteCheckFlg ?? false)

        if cell.isEnabledEdittingLike {
            cell.likeButton(isHidden: cellItems[safe: indexPath.row]?.cellType != .selected)
        } else {
            cell.likeButton(isHidden: true)
        }
        cell.userButton(isHidden: cellItems[safe: indexPath.row]?.cellType != .selected)
        return cell
    }
}

extension TalkingHistoryProvider: DeleteCheckDelegate {
    func didChangeCheckFlg(newValue: Bool, indexPath: IndexPath) {
        self.cellItems[indexPath.row].deleteCheckFlg = newValue
    }
}
