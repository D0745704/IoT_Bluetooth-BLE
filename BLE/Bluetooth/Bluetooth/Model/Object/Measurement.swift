//
//  Measurement.swift
//  Bluetooth
//
//  Created by 仲輝 on 2022/4/27.
//

import Foundation

/*
 uint16 max value = 65535
 超過上限時 從0計數
 因次當出現小於新數據時
 為超過上限之情況
 這時由 (max + 新值) - 舊值
 來做計算
 */

struct Measurement {
    
    var data: Data
    let cumulativeWheel: Int
    let wheelEventTime: Int
    
    var cumulativeCrank: Int
    let crankEventTime: Int
    
    /*
     - 先假設裝置wheel&crank都有提供
     - 值這邊先作轉換
     - 會判斷有無wheel才做切割
     */
    init(data: Data) {
        self.data = data
        let byteArray = [UInt8](data)

        cumulativeWheel = (Int(byteArray[4]) << 24) + (Int(byteArray[3]) << 16)
                         + (Int(byteArray[2]) << 8) + Int(byteArray[1])
        wheelEventTime = (Int(byteArray[6]) << 8) + Int(byteArray[5])
        cumulativeCrank = (Int(byteArray[8]) << 8) + Int(byteArray[7])
        crankEventTime = (Int(byteArray[10]) << 8) + Int(byteArray[9])

    }
      
    //MARK: - 取得資料
    func valuesForPreviousMeasurement(previousData: Measurement?) -> Characteristics? {
        
        var speed: Double = 0
        var cadence: Double = 0
        var distance: Double = 0
        var totalDistance: Double
        var ratio: Double = 0
        
        guard let previousData = previousData else {
            return nil
        }
        
        
        let wheelDiff = wheelRevolutionDiff(current: cumulativeWheel, previous: previousData.cumulativeWheel, max: UInt32.max)
        let crankDiff = crankRevolutionDiff(current: cumulativeCrank, previous: previousData.cumulativeCrank, max: UInt16.max)
        
        let wheelTimeTemp = calculateEventTimeDiff(current: wheelEventTime, previous: previousData.wheelEventTime)
        let crankTimeTemp = calculateEventTimeDiff(current: crankEventTime, previous: previousData.crankEventTime)
        let wheelTimeDiff = Double(wheelTimeTemp) / 1024.0
        let crankTimeDiff = Double(crankTimeTemp) / 1024.0
        
        distance = Double(wheelDiff) * BTConstants.DefaultWheelSize / 1000
        totalDistance = Double(cumulativeWheel) * BTConstants.DefaultWheelSize / 1000
        speed = wheelTimeDiff == 0 ? 0 : (distance * 1000) / wheelTimeDiff
        
        cadence = crankTimeDiff == 0 ? 0 : Double(crankDiff) / crankTimeDiff * 60
        ratio = crankDiff == 0 ? 0 : Double(wheelDiff) / Double(crankDiff)
                
        let sensorData = Characteristics(speed: speed, cadence: cadence, distance: distance, totalDistance: totalDistance, ratio: ratio)
        return sensorData
    }

    //MARK: - 計算用 (不擅長泛型)
    private func wheelRevolutionDiff(current: Int, previous: Int, max: UInt32) -> Int {
        let diff: Int
        
        if current >= previous {
           diff = current - previous
        } else {
            diff = (Int(max) - previous) + current
        }
        return diff
    }

    private func crankRevolutionDiff(current: Int, previous: Int, max: UInt16) -> Int {
        let diff: Int
        
        if current >= previous {
           diff = current - previous
        } else {
            diff = (Int(max) - previous) + current
        }
        return diff
    }

    private func calculateEventTimeDiff(current: Int, previous: Int) -> Int {
        let diff: Int
        
        if current >= previous {
           diff = current - previous
        } else {
            diff = (Int(UInt16.max) - previous) + current
        }

        return diff
    }
}
