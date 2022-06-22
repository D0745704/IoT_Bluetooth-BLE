//
//  SensorValuesViewModel.swift
//  Bluetooth
//
//  Created by 仲輝 on 2022/5/9.
//

import Foundation

class SensorValuesViewModel {
    
    var centralManager: BluetoothManager!
    var delegate: BLEViewModelDelegate?
    
    var accumulatedDistance: Double = 0.0
    
    var speedText: String = "-"
    var cadenceText: String = "-"
    var distanceText: String = "-"
    var totalDistanceText: String = "-"
    var ratioText: String = "-"
    var batteryLevelText: String = "-"

    init() {
        centralManager = BluetoothManager.shared
        CadenceSensor.shared.sensorDelegate = self
    }

    func disconnectToDevice(sensor: CadenceSensor) {
        centralManager.disconnectToSensor(sensor: sensor)
    }
}

extension SensorValuesViewModel: CadenceSensorDelegate {
    
    func sensorUpdatedValues(by values: Characteristics) {
        
        let tempDistance = values.distance
        accumulatedDistance += tempDistance
        
        self.speedText = String(format: "%.2f", values.speed) + " m/s"
        cadenceText = String(format: "%.1f",values.cadence) + " RPM"
        distanceText = String(format: "%.2f", accumulatedDistance) + " km"
        
        totalDistanceText = String(format: "%.2f", values.totalDistance) + " km"
        ratioText = String(format: "%.1f", values.ratio)
        delegate?.callFinished()
    }
    
    func sensorUpdatedBatteryLevel(by battery: BatteryLevel) {
        batteryLevelText = String(battery.batteryLevel) + " %"
        delegate?.callFinished()
    }
}
