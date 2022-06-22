//
//  CadenceSensor.swift
//  Bluetooth
//
//  Created by 仲輝 on 2022/4/18.
//

import CoreBluetooth

protocol CadenceSensorDelegate {
    func sensorUpdatedValues(by _: Characteristics)
    func sensorUpdatedBatteryLevel(by _: BatteryLevel)
}

class CadenceSensor: NSObject {
    
    static var shared = CadenceSensor()
    
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?
    var lastMeasurement: Measurement?
    var sensorDelegate: CadenceSensorDelegate?
    
    private override init() {
    }
    
    func start() {
        self.peripheral!.delegate = self
        self.peripheral!.discoverServices(nil)
    }
    
    func stop() {
        if let characteristic = characteristic {
            peripheral!.setNotifyValue(false, for: characteristic)
        }
    }
    
    func handleData(data: Data) {
        let measurement = Measurement(data: data)
        
        let values = measurement.valuesForPreviousMeasurement(previousData: lastMeasurement)
        let defaultValues = Characteristics(speed: 0, cadence: 0, distance: 0, totalDistance: 0, ratio: 0)
        lastMeasurement = measurement
        sensorDelegate?.sensorUpdatedValues(by: values ?? defaultValues)
    }
}

extension CadenceSensor: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            return
        }
    }
    
    //更新值
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil, let data = characteristic.value else {
            return
        }
        if characteristic.uuid.uuidString == "2A19" {
            let batteryLevel = BatteryLevel(batteryLevel: characteristic.value![0])
            sensorDelegate?.sensorUpdatedBatteryLevel(by: batteryLevel)
        } else if characteristic.uuid.uuidString == "2A5B"{
            handleData(data: data)
        }
    }
    
    //發現設備
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            return
        }
        guard let cadenceService = peripheral.services else { return }
//        guard let cadenceService = peripheral.services?.filter({ (service) -> Bool in
//            return service.uuid == CBUUID(string: BTConstants.CandenceService)
//        }).first else { return }
        for service in cadenceService {
            peripheral.discoverCharacteristics(nil, for: service)

        }
    }
    
    //發現特徵值
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        for characteristic in characteristics {
            print(characteristic)
            if characteristic.uuid == CBUUID(string: BTConstants.CSCMeasurementUUID) {
                peripheral.setNotifyValue(true, for: characteristic)
                self.characteristic = characteristic
            }
            if characteristic.uuid == CBUUID(string: BTConstants.batteryLevel) {
                self.characteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
            }
        }
    }
}
