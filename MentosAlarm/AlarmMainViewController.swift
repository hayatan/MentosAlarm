//
//  AlarmMainViewController.swift
//  MentosAlarm
//
//  Created by hayatan on 2016/11/05.
//  Copyright © 2016年 hayatan. All rights reserved.
//

import UIKit

class AlarmMainViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker! {
        didSet {
            datePicker.minimumDate = Date()
            datePicker.maximumDate = Date(timeIntervalSinceNow: 361440)
        }
    }
    
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var stateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: .changeAlarmServiceState, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            debugPrint("notif")
            self?.updateUI()
        }
        
        self.updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showNotificationPermissionAlertIfNecessary()
        
    }
    
    func showNotificationPermissionAlertIfNecessary() {
        
        guard AlarmService.shared.localNotificationIsNeedGrant else {
            return
        }
        
        let title = "err"
        let message = "通知を許可してけろ"
        
        let closeTitle = "閉じる"
        let closeAction = UIAlertAction(title: closeTitle, style: .default) { (action) in
            // none
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(closeAction)
        
        present(alertController, animated: true) { 
            // none
        }
        
    }
    
    
    func updateUI() {
        switch AlarmService.shared.state {
        case .None:
            
            mainButton.isHidden = false
            mainButton.setTitle("セット", for: .normal)
            
            datePicker.isUserInteractionEnabled = true
            stateLabel.text = "None"
            
        case .CountDown:
            
            mainButton.isHidden = false
            mainButton.setTitle("アラームキャンセル", for: .normal)
            
            datePicker.isUserInteractionEnabled = false
            stateLabel.text = "CountDown"
        case .PrepareStep1:
            
            if AudioPlayService.shared.isPlaying {
                mainButton.isHidden = false
                mainButton.setTitle("音を止める", for: .normal)
            } else {
                mainButton.isHidden = true
                mainButton.setTitle(nil, for: .normal)
            }
            
            datePicker.isUserInteractionEnabled = false
            stateLabel.text = "PrepareStep1"
            
        case .Step1:
            mainButton.isHidden = true
            mainButton.setTitle(nil, for: .normal)
            
            datePicker.isUserInteractionEnabled = false
            stateLabel.text = "Step1"
        case .PrepareMentos:
            
            if AudioPlayService.shared.isPlaying {
                mainButton.isHidden = false
                mainButton.setTitle("音を止める", for: .normal)
            } else {
                mainButton.isHidden = true
                mainButton.setTitle(nil, for: .normal)
            }
            
            datePicker.isUserInteractionEnabled = false
            stateLabel.text = "PrepareMentos"
        case .Mentos:
            mainButton.isHidden = false
            mainButton.setTitle("リセット", for: .normal)
            
            datePicker.isUserInteractionEnabled = false
            stateLabel.text = "Mentos"
        }
    }
    
    @IBAction func didTapMainButton(_ sender: UIButton) {
        
        let state = AlarmService.shared.state
        
        if state == .None {
            AlarmService.shared.newAlarm(date: datePicker.date)
        } else if state == .CountDown {
            AlarmService.shared.state = .None
        } else {
            
            if state == .Mentos {
                AlarmService.shared.state = .None
            }
            
            AudioPlayService.shared.stopAll()
            updateUI()
        }
    }
}

