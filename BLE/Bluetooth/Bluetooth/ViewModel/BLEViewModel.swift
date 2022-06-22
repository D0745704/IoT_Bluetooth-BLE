//
//  BLEViewModel.swift
//  Bluetooth
//
//  Created by 仲輝 on 2022/4/28.
//

import CoreBluetooth

protocol BLEViewModelDelegate {
    func callFinished()
}

class BLEViewModel {
    
    var centralManager: BluetoothManager!
    var sensor: CadenceSensor?
    var sensors = [CBPeripheral]()
    //只掃描特定藍牙裝置
    let servicesToScan = [CBUUID(string: BTConstants.CandenceService)]

    var delegate: BLEViewModelDelegate?
        
    init() {
        centralManager = BluetoothManager.shared
        centralManager.delegate = self
    }
    
    //MARK: - 清空
    func removeArrayData() {
        sensors.removeAll()
    }
    
    //MARK: - 掃描
    func startScanning() {
        //先清空
        removeArrayData()
        centralManager.startScan()
    }
    
    func stopScanning() {
        centralManager.stopScan()
    }
    
    //MARK: - 連線
    func connect(sensor: CadenceSensor) {
        centralManager.connectToSensor(sensor: sensor)
    }
}

extension BLEViewModel: BluetoothManagerDelegate {
            
    func stateChanged(central: CBCentralManager) {
        
        switch central.state {
        case .poweredOn:
            print("Powered ON")
        case .poweredOff:
            print("Powered OFF")
        case .resetting:
            print("Resetting")
        case .unauthorized:
            print("Unauthorized")
        case .unsupported:
            print("Unsupported")
        default:
            print("Unknown")
        }
    }
    
    //發先後畫面更新
    func sensorDiscovered(sensor: CBPeripheral) {
        sensors.append(sensor)
        delegate?.callFinished()
    }
    
    func sensorConnection(sensor: CadenceSensor) {
        self.sensor = sensor
        self.sensor!.start()
    }
    
    //斷開連線沒有實作完
    func sensorDisconnected(sensor: CadenceSensor) {
        self.sensor = nil
    }

}
