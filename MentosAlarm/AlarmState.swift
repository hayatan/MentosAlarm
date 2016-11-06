//
//  AlarmState.swift
//  MentosAlarm
//
//  Created by hayatan on 2016/11/06.
//  Copyright © 2016年 hayatan. All rights reserved.
//

import Foundation

/// アラームの状態
///
/// - None:          初期状態
/// - CountDown:     アラームセットして、まだ発火していないとき
/// - PrepareStep1:  1回目の発火後、Step1の嫌がらせ前
/// - Step1:         Step1の嫌がらせ
/// - PrepareMentos: Step1の嫌がらせの後、メントスの前
/// - Mentos:        メントス！
enum AlarmState {
    case None
    case CountDown
    case PrepareStep1
    case Step1
    case PrepareMentos
    case Mentos
}
