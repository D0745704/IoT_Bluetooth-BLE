//
//  Characteristic.swift
//  Bluetooth
//
//  Created by 仲輝 on 2022/4/19.
//

import Foundation
import UIKit

struct Characteristic {
    
    typealias revolutionAndTime = (revolution: Int,time: Double)
    
    let wheelRevolutionAndTime: revolutionAndTime?
    let crankRevolutionAndTime: revolutionAndTime?
    
    static let zero = Characteristic(wheelRevolutionAndTime: (0, 0.0), crankRevolutionAndTime: (0, 0.0))
    
    //舊資料
    init(wheelRevolutionAndTime: (Int, Double)?, crankRevolutionAndTime: (Int, Double)?) {
        self.wheelRevolutionAndTime = wheelRevolutionAndTime
        self.crankRevolutionAndTime = crankRevolutionAndTime
    }
    //新資料
    //MARK: - 數據
    //距離&總距離
    func distance(_ pre: Characteristic, wheelCircumference: Double) -> Measurement<UnitLength>? {
        wheelRevolutionDiff(pre).flatMap{ Measurement<UnitLength>(value: Double($0) * wheelCircumference, unit: .meters) }
    }
    func totalDistance(wheelCircumference: Double) -> Measurement<UnitLength>? {
        wheelRevolutionAndTime.map{ Measurement<UnitLength>(value: Double($0.revolution) * wheelCircumference, unit: .meters) }
    }
    
    //齒輪比 大的/小的 => wheel/crank
    func gearRatio(_ pre: Characteristic) -> Double? {
        guard let wheelRevolutionDiff = wheelRevolutionDiff(pre), let crankRevolutionDiff = crankRevolutionDiff(pre), crankRevolutionDiff != 0 else {
            return nil
        }
        
        return Double(wheelRevolutionDiff) / Double(crankRevolutionDiff)
    }
    
    func speed(_ pre: Characteristic, wheelCircumference: Double) -> Measurement<UnitSpeed>? {
        guard let wheelRevolutionDiff = wheelRevolutionDiff(pre), let wheelEventTime = wheelRevolutionAndTime?.time, let preWheelEventTime = pre.wheelRevolutionAndTime?.time else {
            return nil
        }
        
        var wheelEventTimeDiff = wheelEventTime - preWheelEventTime
        guard preWheelEventTime > 0 else {
            return nil
        }
        
        wheelEventTimeDiff /= 1024
        
        let speed = (Double(wheelRevolutionDiff) * wheelCircumference) / wheelEventTimeDiff
        
        return Measurement<UnitSpeed>(value: speed, unit: .kilometersPerHour)
    }
    
    func cadence(_ pre: Characteristic) -> Int? {
        guard let crankRevolutionDiff = crankRevolutionDiff(pre), let crankEventTimeDiff = crankEventTimeDiff(pre), crankEventTimeDiff > 0 else {
            return nil
        }
        
        return Int(Double(crankRevolutionDiff) / crankEventTimeDiff * 60.0)
    }
    
    //MARK: - 計算
    func wheelRevolutionDiff(_ pre: Characteristic) -> Int? {
        guard let preWheelRevolution = pre.wheelRevolutionAndTime?.revolution, let wheelRevolution = wheelRevolutionAndTime?.revolution else {
            return nil
        }
        guard preWheelRevolution != 0 else { return 0 }
        return wheelRevolution - preWheelRevolution
    }
    
    func crankRevolutionDiff(_ pre: Characteristic) -> Int? {
        guard let crankRevolution = crankRevolutionAndTime?.revolution, let preCrankRevolution = pre.crankRevolutionAndTime?.revolution else {
            return nil
        }
        
        return crankRevolution - preCrankRevolution
    }
    
    func crankEventTimeDiff(_ pre: Characteristic) -> Double? {
        guard let crankEventTime = crankRevolutionAndTime?.time, let preCrankEventTime = pre.crankRevolutionAndTime?.time else {
            return nil
        }
        
        return (crankEventTime - preCrankEventTime) / 1024
    }
}

