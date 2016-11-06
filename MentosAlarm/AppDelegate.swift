//
//  AppDelegate.swift
//  MentosAlarm
//
//  Created by hayatan on 2016/11/05.
//  Copyright © 2016年 hayatan. All rights reserved.
//

import UIKit
import CoreAudio
import CoreAudioKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var cnt = 0
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        AlarmService.shared.setup()
        BackgroundRoopTaskService.shared.setup()
        AudioPlayService.shared.setup()
        return true
    }
    

}

