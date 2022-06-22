//
//  SensorTableViewController.swift
//  Bluetooth
//
//  Created by 仲輝 on 2022/4/11.
//

import UIKit

class SensorTableViewController: UITableViewController {
    
    var dataType = ["Speed","Cadence","Distance","Total Distance","Gear Ratio"]
    //MARK: 接上第二個VM
    var valueViewModel = SensorValuesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        valueViewModel.delegate = self
    }
    
    func textLabelColor() {
        
    }
    
    @IBAction func disconnect(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
            
        case 0: return "SPEED AND CADENCE"
        case 2: return "CONNECTION"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? dataType.count : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> CharacteristicsTableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BLECell", for: indexPath) as! CharacteristicsTableViewCell
            cell.type.text = dataType[indexPath.row]
            cell.dataValue.textColor = UIColor.systemGray
            cell.dataValue.font = UIFont.systemFont(ofSize: 16)
            
            switch indexPath.row {
            case 0:
                cell.dataValue.text = valueViewModel.speedText
            case 1:
                cell.dataValue.text = valueViewModel.cadenceText
            case 2:
                cell.dataValue.text = valueViewModel.distanceText
            case 3:
                cell.dataValue.text = valueViewModel.totalDistanceText
            case 4:
                cell.dataValue.text = valueViewModel.ratioText
            default:
                cell.dataValue.text = "-"
            }
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BatteryCell", for: indexPath) as! CharacteristicsTableViewCell
            cell.batteryLevel.text = valueViewModel.batteryLevelText
            cell.batteryLevel.font = UIFont.systemFont(ofSize: 16)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectionCell", for: indexPath) as! CharacteristicsTableViewCell
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            valueViewModel.disconnectToDevice(sensor: CadenceSensor.shared)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
    
extension SensorTableViewController: BLEViewModelDelegate {
    
    func callFinished() {
        self.tableView.reloadData()
    }
}


