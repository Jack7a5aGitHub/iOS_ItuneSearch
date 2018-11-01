//
//  ReverseGeocoding.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/22.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import CoreLocation
import UIKit

protocol ReverseGeocodingDelegate: class {
    func didReceiveReverseGeocodeResponse(locality: String, country: String)
}

final class ReverseGeocoding {

    weak var delegate: ReverseGeocodingDelegate?

    func placemark(latitude: Double, longitude: Double) {

        print("latitude: \(latitude)")
        print("longitude: \(longitude)")

        CLGeocoder().reverseGeocodeLocation(
            CLLocation(latitude: latitude, longitude: longitude),
            completionHandler: { placemarks, _ in
                guard
                    let placemark = placemarks?.first,
                    let locality = placemark.locality,
                    let country = placemark.country else {
                        return
                }
                print("locality: \(locality)")
                print("country: \(country)")
                self.delegate?.didReceiveReverseGeocodeResponse(locality: locality, country: country)
        })
    }
}
