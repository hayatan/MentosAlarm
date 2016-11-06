//
//  MentoApiRecord.swift
//  MentosAlarm
//
//  Created by hayatan on 2016/11/06.
//  Copyright © 2016年 hayatan. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class MentoApiRecord {
    
    let path = "/record.json"
    
    func GET(app: String = MentosAPIUtil.appId, id: String, completationHandler: @escaping (_ json: JSON, _ error: Error?) -> Void) {
        Alamofire
            .request(MentosAPIUtil.baseURL + path,
                     method: HTTPMethod.get,
                     parameters: ["app": app, "id": id],
                     encoding: URLEncoding.init(),
                     headers: [
                        MentosAPIUtil.apiKeyHedderField: MentosAPIUtil.apiKey,
                        MentosAPIUtil.authorizationHedderField: MentosAPIUtil.authorization
                ])
            
            .responseJSON { (dataResponse) in
                
                debugPrint(#function, dataResponse.result.value, dataResponse.result.error)
                completationHandler(JSON(dataResponse.result.value), dataResponse.result.error)
        }
    }
    
    
    func POST(app: String = MentosAPIUtil.appId, record: [String: AnyObject], completationHandler: @escaping (_ json: JSON, _ error: Error?) -> Void) {
        var parameters: [String: AnyObject] = ["app": app as AnyObject]
        if let record = record as AnyObject? {
            parameters["record"] = record
        }

        Alamofire
            .request(MentosAPIUtil.baseURL + path,
                     method: HTTPMethod.post,
                     parameters: parameters,
                     encoding: JSONEncoding.init(),
                     headers: [
                MentosAPIUtil.apiKeyHedderField: MentosAPIUtil.apiKey
                ])
            
            .responseJSON { (dataResponse) in
                
                debugPrint(#function, dataResponse.result.value, dataResponse.result.error)
                completationHandler(JSON(dataResponse.result.value), dataResponse.result.error)
                
        }
    }
    
    
    func PUT(app: String = MentosAPIUtil.appId, id: String, record: [String: AnyObject], completationHandler: @escaping (_ json: JSON, _ error: Error?) -> Void) {
        let parameters: [String: AnyObject] = [
            "app": app as AnyObject,
            "id": id as AnyObject,
            "record": record as AnyObject
        ]
        
        Alamofire
            .request(MentosAPIUtil.baseURL + path,
                     method: HTTPMethod.put,
                     parameters: parameters,
                     encoding: JSONEncoding.init(),
                     headers: [
                        MentosAPIUtil.apiKeyHedderField: MentosAPIUtil.apiKey
                ])
            
            .responseJSON { (dataResponse) in
                
                debugPrint(#function, dataResponse.result.value, dataResponse.result.error)
                completationHandler(JSON(dataResponse.result.value), dataResponse.result.error)
        }
    }
    
}


