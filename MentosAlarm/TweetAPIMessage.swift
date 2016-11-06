//
//  TweetAPIMessage.swift
//  MentosAlarm
//
//  Created by hayatan on 2016/11/06.
//  Copyright © 2016年 hayatan. All rights reserved.
//

import Foundation
import Alamofire

class TweetAPIMessage {
    
    
    let url = "http://laboccio.com/rak/twitter.php?g=1106"
    
    func send() {
        request(url).responseString { (dataResponse) in
            debugPrint(#function, dataResponse.result.value)
        }
    }
    
}
