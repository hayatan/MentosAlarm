//
//  AudioPlayService.swift
//  MentosAlarm
//
//  Created by hayatan on 2016/11/06.
//  Copyright © 2016年 hayatan. All rights reserved.
//

import Foundation
import AVFoundation

// アラーム音：魔王魂

class AudioPlayService: NSObject, AVAudioPlayerDelegate {
    
    /// シングルトン
    static let shared = AudioPlayService()
    
    private override init() {
        super.init()
    }
    
    private var alarmAudioPlayer : AVAudioPlayer?
    private var alertAudioPlayer : AVAudioPlayer?
    
    var isPlaying: Bool {
        return alarmAudioPlayer?.isPlaying ?? false || alertAudioPlayer?.isPlaying ?? false
    }
    
    func setup() {
        // アラーム音
        if let alarmFilePath = Bundle.main.path(forResource: "alarm", ofType: "mp3") {
            
            let url = URL(fileURLWithPath: alarmFilePath)
            
            //AVAudioPlayerのインスタンス化.
            try? alarmAudioPlayer = AVAudioPlayer(contentsOf: url)
            
            //AVAudioPlayerのデリゲートをセット.
            alarmAudioPlayer?.delegate = self
            
            // 無限リピート
            alarmAudioPlayer?.numberOfLoops = -1
        }
        
        // アラート音
        if let alertFilePath = Bundle.main.path(forResource: "alert", ofType: "mp3") {
            
            let url = URL(fileURLWithPath: alertFilePath)
            
            //AVAudioPlayerのインスタンス化.
            try? alertAudioPlayer = AVAudioPlayer(contentsOf: url)
            
            //AVAudioPlayerのデリゲートをセット.
            alertAudioPlayer?.delegate = self
            
            // 無限リピート
            alertAudioPlayer?.numberOfLoops = -1
        }
        
        /// バックグラウンドでも再生できるカテゴリに設定する
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch  {
            // エラー処理
            fatalError("カテゴリ設定失敗")
        }
        
        // sessionのアクティブ化
        do {
            try session.setActive(true)
        } catch {
            // audio session有効化失敗時の処理
            // (ここではエラーとして停止している）
            fatalError("session有効化失敗")
        }
        
    }
    
    func playAlarm() {
        if alarmAudioPlayer?.isPlaying == false {
            alarmAudioPlayer?.play()
        }
    }
    
    func playAlert() {
        if alertAudioPlayer?.isPlaying == false {
            alertAudioPlayer?.play()
        }
    }
    
    
    func stopAll() {
        if alarmAudioPlayer?.isPlaying == true {
            alarmAudioPlayer?.pause()
        }
        
        if alertAudioPlayer?.isPlaying == true {
            alertAudioPlayer?.pause()
        }
    }
    
}
