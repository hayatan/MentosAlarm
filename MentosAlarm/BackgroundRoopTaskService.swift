//
//  BackgroundRoopTaskService.swift
//  MentosAlarm
//
//  Created by hayatan on 2016/11/06.
//  Copyright © 2016年 hayatan. All rights reserved.
//

import Foundation
import CoreLocation

class BackgroundRoopTaskService:NSObject, CLLocationManagerDelegate {
    
    static let shared = BackgroundRoopTaskService()
    
    let manager = CLLocationManager()
    
    private override init() {
        super.init()
    }
    
    func setup() {
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.pausesLocationUpdatesAutomatically = false
        manager.startUpdatingLocation()
    }
    
    var tasks: [String: (() -> Void)?] = [:]
    
    func registerBackgroundTask(interval: TimeInterval, task: @escaping () -> Void) {
        let uuid = UUID().uuidString
        let timer = Timer(timeInterval: interval, target: self, selector: #selector(executeBackgroundTask(timer:)), userInfo: uuid, repeats: false)
        tasks[uuid] = task
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    func executeBackgroundTask(timer: Timer) {
        if let uuid = timer.userInfo as? String {
            let task = tasks[uuid] ?? nil
            task?()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        debugPrint("didUpdateLocations")
    }
    
}
