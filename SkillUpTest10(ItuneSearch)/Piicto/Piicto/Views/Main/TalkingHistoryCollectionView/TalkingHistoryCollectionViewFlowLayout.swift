//
//  TalkingHistoryCollectionViewFlowLayout.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/07.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import UIKit

final class TalkingHistoryCollectionViewFlowLayout: UICollectionViewFlowLayout {

    let layoutAttributesMargin: CGFloat = 10.0

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        var newAttributes = [UICollectionViewLayoutAttributes]()
        for attribute in attributes {
            guard let copyAttribute = attribute.copy() as? UICollectionViewLayoutAttributes else {
                continue
            }
            let newBounds = CGRect(x: copyAttribute.bounds.origin.x,
                                   y: copyAttribute.bounds.origin.y,
                                   width: copyAttribute.bounds.size.width,
                                   height: copyAttribute.bounds.size.height + layoutAttributesMargin + 1)
            copyAttribute.bounds = newBounds
            newAttributes.append(copyAttribute)
        }
        return newAttributes
    }
}
