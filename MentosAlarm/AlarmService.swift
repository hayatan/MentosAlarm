//
//  AlarmService.swift
//  MentosAlarm
//
//  Created by hayatan on 2016/11/05.
//  Copyright © 2016年 hayatan. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit
import SwiftyJSON

extension Notification.Name {
    static let changeAlarmServiceState = Notification.Name("changeAlarmServiceState")
}

class AlarmService:NSObject, UNUserNotificationCenterDelegate {
    
    let prepareStep1Interval: TimeInterval = 20
    let step1Interval: TimeInterval = 10
    let prepareMentosInterval: TimeInterval = 20
    
    let alarmFireNotificationIdentifer = "alarmFireNotificationIdentifer"
    let prepareMentosFireNotificationIdentifer = "prepareMentosFireNotificationIdentifer"
    
    /// シングルトン
    static let shared = AlarmService()
    
    /// アラームの状態
    var state = AlarmState.None {
        didSet {
            debugPrint("before:", oldValue, "now:", state)
            didActive(before: oldValue)
            NotificationCenter.default.post(name: .changeAlarmServiceState, object: nil)
        }
    }
    
    private(set) var recordId: String?
    
    var countdownInterval: TimeInterval = 0
    
    // MARK: - LocalNotification Properties
    
    
    /// ユーザー通知Center
    private let center = UNUserNotificationCenter.current()
    
    
    /// ユーザー通知は許可されているか
    private var isGranted = false
    
    
    /// ユーザー通知承認リクエストは済んでいるか
    private var isAuthorizationRequested: Bool {
        set {
            let key = "AlarmServiceLocalNotificationAuthorizationRequestedUDKey"
            UserDefaults.standard.set(newValue, forKey: key)
        }
        get {
            let key = "AlarmServiceLocalNotificationAuthorizationRequestedUDKey"
            return UserDefaults.standard.bool(forKey: key)
        }
    }
    
    
    /// ユーザーに手動で通知をONにしてもらう必要があるか
    var localNotificationIsNeedGrant: Bool {
        return !isGranted && isAuthorizationRequested
    }
    
    
    // MARK: - Initialize
    
    private override init() {
        
    }
    
    
    /// セットアップ
    func setup() {
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] (granted, error) in
            self?.isGranted = granted
            self?.isAuthorizationRequested = true
            
            // Debug
            if self?.isGranted == true {
                print("Notification is Granted")
            }
        }
        
        center.delegate = self
        
        // 画面ロックしない
        UIApplication.shared.isIdleTimerDisabled = true
        
    }
    
    
    
    // MARK: - アラーム操作
    
    /// アラーム設定
    ///
    /// - parameter date: 設定時刻
    func newAlarm(date: Date) {
        
        recordId = nil
        
        countdownInterval = date.timeIntervalSince(Date())
        if countdownInterval < 1 {
            countdownInterval = 1
        }
        state = .CountDown
        
        debugPrint(#function, date, countdownInterval)
        
    }
    
    
    // MARK: - State machine
    
    private func didActive(before: AlarmState) {
        
        switch state {
        case .None:
            
            // Any -> CountDown
            // すべての通知を削除
            center.removeAllPendingNotificationRequests()
            // 音を止める
            AudioPlayService.shared.stopAll()
            
            break
            
        case .CountDown:
            
            // None -> CountDown
            if before == .None {
                // アラーム情報をPOST
                MentoApiRecord().POST(record: [:], completationHandler: { [weak self] (json, error) in
                    
                    guard let `self` = self else {
                        return
                    }
                    
                    if let error = error {
                        debugPrint(error.localizedDescription)
                        self.state = .None
                        return
                    }
                    
                    guard let id = json["id"].string else {
                        self.state = .None
                        return
                    }
                    
                    
                    // レコードIDを保持
                    self.recordId = id
                    
                    // countdownInterval 後にローカル通知を設定
                    self.registerUserNotification(timeInterval: self.countdownInterval,
                                                  identifier: self.alarmFireNotificationIdentifer,
                                                  title: "おきろー！！",
                                                  message: "はやくおきて！！")
                    
                    // countdownInterval 後に PrepareStep1にする
                    BackgroundRoopTaskService.shared.registerBackgroundTask(interval: self.countdownInterval, task: { [weak self] in
                        self?.state = .PrepareStep1
                        })
                    })
                
            } else {
                // これはエラー
                debugPrint("あり得ない状態遷移")
                state = .None
            }
            
        case .PrepareStep1:
            
            // CountDown -> PrepareStep1
            if before == .CountDown {
                // アラーム音を再生
                AudioPlayService.shared.playAlarm()
                
                // prepareStep1Interval 後に Step1にする
                BackgroundRoopTaskService.shared.registerBackgroundTask(interval: prepareStep1Interval, task: { [weak self] in
                    self?.state = .Step1
                    })
            } else {
                // これはエラー
                debugPrint("あり得ない状態遷移")
                state = .None
            }
            
        case .Step1:
            
            // PrepareStep1 -> Step1
            if before == .PrepareStep1 {
                // GET
                
                guard let recordId = recordId else {
                    debugPrint("レコードIDがない")
                    state = .None
                    return
                }
                
                MentoApiRecord().GET(id: recordId, completationHandler: {[weak self] (json, error) in
                    
                    guard let `self` = self else {
                        return
                    }
                    
                    if let error = error {
                        debugPrint(error.localizedDescription)
                        self.state = .None
                        return
                    }
                    
                    
                    guard let senmen = json["record"]["senmen"]["value"].string else {
                            self.state = .None
                            return
                    }
                    
                    
                    if senmen == "none" {
                        
                        // ツイッター投稿
                        TweetAPIMessage().send()
                        
                        // step1 = "gone" でPUT
                        MentoApiRecord().PUT(id: recordId, record: ["step1": ["value": "gone" as AnyObject] as AnyObject], completationHandler: { [weak self] (json, error) in
                            
                            guard let `self` = self else {
                                return
                            }
                            
                            if let error = error {
                                debugPrint(error.localizedDescription)
                                self.state = .None
                                return
                            }
                            
                            
                            // step1Interval 後にローカル通知を設定\
                            self.registerUserNotification(timeInterval: self.step1Interval,
                                                          identifier: self.prepareMentosFireNotificationIdentifer,
                                                          title: "ツイッターに投稿しちゃった☆(`ゝω･´)vｷｬﾋﾟｨ",
                                                          message: "はやくおきて！！やばいことになるよ！！！！！まじでやばい！！！")
                            
                            
                            // step1Interval 後に PrepareMentosにする
                            BackgroundRoopTaskService.shared.registerBackgroundTask(interval: self.step1Interval, task: {[weak self] in
                                self?.state = .PrepareMentos
                                })
                            
                            })
                        
                    } else if senmen == "gone" {
                        // StateをNoneに
                        self.state = .None
                    } else {
                        // これはエラー
                        debugPrint("あり得ないレスポンス")
                        self.state = .None
                    }
                    
                    })
                
                
            } else {
                // これはエラー
                debugPrint("あり得ない状態遷移")
                state = .None
            }
            
        case .PrepareMentos:
            
            // Step1 -> PrepareMentos
            if before == .Step1 {
                // アラーム音を再生
                AudioPlayService.shared.playAlarm()
                
                // prepareMentosInterval 後に Mentosにする
                BackgroundRoopTaskService.shared.registerBackgroundTask(interval: prepareMentosInterval, task: {[weak self] in
                    self?.state = .Mentos
                    })
                
            } else {
                // これはエラー
                debugPrint("あり得ない状態遷移")
                state = .None
            }
            
        case .Mentos:
            
            // PrepareStep1 -> Step1
            if before == .PrepareMentos {
                
                // GET
                guard let recordId = recordId else {
                    debugPrint("レコードIDがない")
                    state = .None
                    return
                }
                
                MentoApiRecord().GET(id: recordId, completationHandler: {[weak self] (json, error) in
                    
                    guard let `self` = self else {
                        return
                    }
                    
                    if let error = error {
                        debugPrint(error.localizedDescription)
                        self.state = .None
                        return
                    }
                    
                    guard let senmen = json["record"]["senmen"]["value"].string else {
                            self.state = .None
                            return
                    }
                    
                    if senmen == "none" {
                        
                        // mentos = "gone" でPOST
                        MentoApiRecord().PUT(id: recordId, record: ["mentos": ["value": "gone" as AnyObject] as AnyObject], completationHandler: { [weak self] (json, error) in
                            
                            guard let `self` = self else {
                                return
                            }
                            
                            if let error = error {
                                debugPrint(error.localizedDescription)
                                self.state = .None
                                return
                            }
                            
                            
                            
                            // なんかヤバそうな音楽を再生
                            AudioPlayService.shared.stopAll()
                            AudioPlayService.shared.playAlert()
                            })
                        
                        
                    } else if senmen == "clear" {
                        // StateをNoneに
                        self.state = .None
                    } else {
                        // これはエラー
                        debugPrint("あり得ないレスポンス")
                        self.state = .None
                    }
                    })
                
            } else {
                // これはエラー
                debugPrint("あり得ない状態遷移")
                state = .None
            }
        }
        
        
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    /// ユーザー通知を設定
    ///
    /// - parameter timeInterval: 発火までの秒数
    /// - parameter identifier: 通知の識別子
    func registerUserNotification(timeInterval: TimeInterval, identifier: String, title: String, message: String) {
        
        // UNMutableNotificationContent 作成
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        
        // timeInterval 秒後に発火する UNTimeIntervalNotificationTrigger 作成、
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: timeInterval, repeats: false)
        
        // identifier, content, trigger から UNNotificationRequest 作成
        let request = UNNotificationRequest.init(identifier: identifier, content: content, trigger: trigger)
        
        // UNUserNotificationCenter に request を追加
        center.add(request)
        
    }
    
    // アプリが foreground の時に通知を受け取った時に呼ばれるメソッド
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        debugPrint("fire! notification ID:\(notification.request.identifier)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        debugPrint("opened")
        completionHandler()
    }
    
}
