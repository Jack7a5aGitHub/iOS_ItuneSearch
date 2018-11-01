//
//  LibraryViewController.swift
//  Piicto
//
//  Created by kawaharadai on 2018/01/28.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController {

    @IBOutlet weak private var libraryView: UICollectionView!
    
    let provider = LibraryViewProvider()
    let margin: CGFloat = 1
    
    private var photoList = [URL]()
    
    // MARK: - Factory
    
    class func make(photoList: [URL]) -> LibraryViewController {
        let vcName = LibraryViewController.className
        guard let libraryVC = UIStoryboard.viewController(
            storyboardName: vcName, identifier: vcName) as? LibraryViewController else {
                fatalError("LibraryViewController is nil.")
        }
       
        libraryVC.photoList = photoList
        
        return libraryVC
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Private
    
    private func setup() {
        provider.photoData = self.photoList
        libraryView.dataSource = provider
        libraryView.delegate = self
    }
}

extension LibraryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        let tapedCell = collectionView.cellForItem(at: indexPath) as? LibraryViewCell
        
        guard let selectPhoto = tapedCell?.photoView.image else {
            print("画像取得に失敗しました。")
            return
        }
        // TODO: SendViewに選択した写真をUIImageとして受け渡して遷移する
        print(indexPath.row)
    }
}

extension LibraryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width: CGFloat = UIScreen.main.bounds.width / 3 - margin * 2
        let height = width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
}
