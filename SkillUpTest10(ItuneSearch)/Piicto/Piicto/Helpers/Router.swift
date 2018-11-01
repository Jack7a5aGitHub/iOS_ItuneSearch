//
//  Router.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/28.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import Alamofire

enum Router: URLRequestConvertible {

    #if DEVELOPMENT
    static let baseURLString = "https://us-central1-ios-piicto-dev.cloudfunctions.net/receiveHTTPRequest"
    #elseif STAGING
    static let baseURLString = "https://us-central1-piicto-dev.cloudfunctions.net/receiveHTTPRequest"
    #else
    static let baseURLString = "https://us-central1-piicto-dev.cloudfunctions.net/receiveHTTPRequest"
    #endif

    case initialImageAPI([String: Any])

    func asURLRequest() throws -> URLRequest {

        let (method, path, parameters): (HTTPMethod, String, [String: Any]) = {

            switch self {
            case .initialImageAPI(let params):
                return (.post, "", params)
            }
        }()

        if let url = URL(string: Router.baseURLString) {
            var urlRequest = URLRequest(url: url.appendingPathComponent(path))
            urlRequest.httpMethod = method.rawValue
            return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
        } else {
            fatalError("url is nil.")
        }
    }
}
