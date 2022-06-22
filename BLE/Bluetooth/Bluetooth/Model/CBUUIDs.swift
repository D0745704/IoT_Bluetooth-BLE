//
//  CBUUIDs.swift
//  Bluetooth
//
//  Created by 仲輝 on 2022/4/8.
//

import CoreBluetooth

struct BTConstants {
    
    static let CandenceService = "1816"
    static let CSCMeasurementUUID = "2A5B"
    //電池UUID
    static let batteryLevel = "2A19"
    //解析數據遮罩
    static let WheelFlagMask:UInt8    = 0b01
    static let CrankFlagMask:UInt8    = 0b10

    
    //MARK: - 暫用
    static let DefaultWheelSize: Double = 2.198 //m
    //計算用時間常數
    static let TimeScale = 1024.0
}
