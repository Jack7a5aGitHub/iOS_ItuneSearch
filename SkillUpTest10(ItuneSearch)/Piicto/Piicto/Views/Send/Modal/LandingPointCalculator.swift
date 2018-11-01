//
//  LandingPointCalculator.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/29.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import UIKit

final class LandingPointCalculator {

    static let earthRadius: Double = 6378150.0

    static func landingPoint(latitude: Double, longitude: Double, distance: Double, heading: Double) -> LandingPoint {

        // 緯線上の移動距離
        let latitudeDistance = distance * cos(heading * Double.pi / 180.0)

        // 1mあたりの緯度
        let earthCircle = 2.0 * Double.pi * earthRadius
        let latitudePerMeter = 360.0 / earthCircle

        // 緯度の変化量
        let latitudeDelta = latitudeDistance * latitudePerMeter
        let newLatitude = latitude + latitudeDelta

        // 経線上の移動距離
        let longitudeDistance = distance * sin(heading * Double.pi / 180.0)

        // 1mあたりの経度
        let earthRadiusAtLongitude = earthRadius * cos(newLatitude * Double.pi / 180.0)
        let earthCircleAtLongitude = 2 * Double.pi * earthRadiusAtLongitude
        let longitudePerMeter = 360.0 / earthCircleAtLongitude

        // 経度の変化量
        let longitudeDelta = longitudeDistance * longitudePerMeter

        return LandingPoint(latitude: newLatitude, longitude: longitude + longitudeDelta)
    }
}

struct LandingPoint {
    var latitude = Double(0)
    var longitude = Double(0)
}
