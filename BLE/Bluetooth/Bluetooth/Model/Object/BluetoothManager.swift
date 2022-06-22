//
//  BluetoothManager.swift
//  Bluetooth
//
//  Created by 仲輝 on 2022/4/15.
//

import CoreBluetooth

protocol BluetoothManagerDelegate {
    
    func stateChanged(central: CBCentralManager)
    func sensorDiscovered(sensor: CBPeripheral)
    func sensorConnection(sensor: CadenceSensor)
    func sensorDisconnected(sensor: CadenceSensor)

}

//待整理完 開始搬
class BluetoothManager: NSObject {
        
    static var shared = BluetoothManager()
    
    var centralManager: CBCentralManager
    var delegate: BluetoothManagerDelegate?
    let servicesToScan = [CBUUID(string: BTConstants.CandenceService)]
    
    override init() {
        
        centralManager = CBCentralManager()
        super.init()
        centralManager.delegate = self
    }
    
    deinit {
        stopScan()
    }
    
    //掃描
    func startScan() {
        centralManager.scanForPeripherals(withServices: servicesToScan)
    }
    
    func stopScan() {
        if centralManager.isScanning {
            centralManager.stopScan()
        }
    }
    
    //連接
    func connectToSensor(sensor: CadenceSensor) {
        centralManager.connect(sensor.peripheral!)
    }

    func disconnectToSensor(sensor: CadenceSensor) {
        centralManager.cancelPeripheralConnection(sensor.peripheral!)
    }
    
}

extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        delegate?.stateChanged(central: central)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //MARK: 先不生成
        let bikeSensor = peripheral
        print("test: find")
        //print(peripheral)
        delegate?.sensorDiscovered(sensor: bikeSensor)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connect completly")
        //MARK: 連接時生成
        delegate?.sensorConnection(sensor: CadenceSensor.shared)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnect!")
        delegate?.sensorDisconnected(sensor: CadenceSensor.shared)
    }
}
