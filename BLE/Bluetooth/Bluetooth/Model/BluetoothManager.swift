//
//  BluetoothManager.swift
//  Bluetooth
//
//  Created by 仲輝 on 2022/4/7.
//

import UIKit
import CoreBluetooth

protocol BluetoothManagerDelegate {
    
}

class BluetoothManager: NSObject {
    
    let bluetoothCentral: CBCentralManager!
    var bluetoothDelegate: BluetoothManagerDelegate?
    let servicesToScan = [CBUUID(string: "BTConstants")]
    
    override init() {
        bluetoothCentral = CBCentralManager()
        super.init()
        //bluetoothCentral.delegate = self
    }
    
    deinit {
        stopScan()
    }
    
    func startScan() {
        
    }
    
    func stopScan() {
        
    }
}
