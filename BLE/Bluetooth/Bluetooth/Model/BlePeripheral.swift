//
//  BlePeripheral.swift
//  Bluetooth
//
//  Created by 仲輝 on 2022/4/12.
//

import Foundation

struct Characteristics {
    var speed: Double
    var cadence: Double
    var distance: Double
    var totalDistance: Double
    var ratio: Double
}

struct BatteryLevel {
    var batteryLevel: UInt8
}
