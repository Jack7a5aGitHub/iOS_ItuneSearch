//
//  InitialImageAPIResponse.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/28.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import ObjectMapper

struct InitialImageAPIResponse: Mappable {

    var success = false
    var statusCode = 0
    var description = ""
    var receiverID = ""

    init?(map: Map) {}

    mutating func mapping(map: Map) {

        success <- map["success"]
        statusCode <- map["status_code"]
        description <- map["description"]
        receiverID <- map["receiver_id"]
    }
}
