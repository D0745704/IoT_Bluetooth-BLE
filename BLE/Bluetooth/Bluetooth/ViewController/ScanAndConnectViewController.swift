//
//  ScanAndConnectViewController.swift
//  Bluetooth
//
//  Created by 仲輝 on 2022/4/6.
//

import UIKit

class ScanAndConnectViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scanningView: UIView!
    @IBOutlet weak var scanningButton: UIButton!
    @IBOutlet weak var scanningLabel: UILabel!
    
    var viewModel = BLEViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.tableView.reloadData()
    }
    
    private func setUp() {
        viewModel.delegate = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        scanningView.clipsToBounds = true
        scanningView.layer.cornerRadius = 15.0
    }
    
    func startScanning() {
        scanningButton.isEnabled = false
        scanningLabel.text = "scanning..."
        self.viewModel.startScanning()
    }
    
    func stopScanning() {
        scanningButton.isEnabled = true
        scanningLabel.text = "-"
        viewModel.stopScanning()
    }

    //MARK: - 下一頁
    func delayedConnection() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.pushToServiceVC()
        })
    }
    
    func pushToServiceVC() {
        let serviceVC = self.storyboard?.instantiateViewController(withIdentifier: "ServiceVC") as! SensorTableViewController
        //serviceVC.viewModel = self.viewModel
        
        let rootNav = UINavigationController(rootViewController: serviceVC)
        rootNav.modalPresentationStyle = .fullScreen
        self.present(rootNav, animated: true)
    }

    //MARK: - 按鈕方法:掃描
    @IBAction func scanningAction(_ sender: Any) {
        startScanning()
        self.tableView.reloadData()
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) {_ in
            self.stopScanning()
        }
    }
}

extension ScanAndConnectViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sensors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BluetoothCell",
                                                 for: indexPath) as! BluetoothTableCell
        let peripheralFound = viewModel.sensors[indexPath.row]
        cell.deviceName.text = peripheralFound.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //MARK: - singleton
        CadenceSensor.shared.peripheral = viewModel.sensors[indexPath.row]
        viewModel.connect(sensor: CadenceSensor.shared)
        
        delayedConnection()
    }
}

extension ScanAndConnectViewController: BLEViewModelDelegate {
    
    func callFinished() {
        self.tableView.reloadData()
    }
}
