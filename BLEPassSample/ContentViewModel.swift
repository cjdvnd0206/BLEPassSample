//
//  ContentViewModel.swift
//  BLEPassSample
//
//  Created by user on 2022/07/13.
//

import Foundation
import CoreBluetooth

final class ContentViewModel: NSObject, ObservableObject {
    var centralManager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral?
    var transferCharacteristic: CBCharacteristic?
    private var characteristic: CBCharacteristic?
    var connectedPeripheral : CBPeripheral?
    let serviceUUID = CBUUID(string: "19B10000-E8F2-537E-4F6C-D104768A1214")
    let characteristicUUID = CBUUID(string: "19B10001-E8F2-537E-4F6C-D104768A1214")
    private var writeType: CBCharacteristicWriteType = .withoutResponse
    @Published var id = ""
    
    func setupCentralManager() {
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    func sendMessageToDevice(_ message: String) {
        if let data = message.data(using: .utf8), let characteristic = characteristic {
            connectedPeripheral?.writeValue(data, for: characteristic, type: writeType)
        }
    }
}
extension ContentViewModel: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .poweredOn:
            // ... so start working with the peripheral
            print("CBManager is powered on")
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        case .poweredOff:
            print("CBManager is not powered on")
            // In a real app, you'd deal with all the states accordingly
            return
        case .resetting:
            print("CBManager is resetting")
            // In a real app, you'd deal with all the states accordingly
            return
        case .unauthorized:
            // In a real app, you'd deal with all the states accordingly
            print("Unexpected authorization")
            return
        case .unknown:
            print("CBManager state is unknown")
            // In a real app, you'd deal with all the states accordingly
            return
        case .unsupported:
            print("Bluetooth is not supported on this device")
            // In a real app, you'd deal with all the states accordingly
            return
        @unknown default:
            print("A previously unknown central manager state occurred")
            // In a real app, you'd deal with yet unknown cases that might occur in the future
            return
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        
        // Reject if the signal strength is too low to attempt data transfer.
        // Change the minimum RSSI value depending on your app’s use case.
        guard RSSI.intValue >= -90
            else {
                print("Discovered perhiperal not in expected range, at \(RSSI.intValue)")
                return
        }
        
        print("Discovered \(String(describing: peripheral.name)) at \(RSSI.intValue)")
        
        // Device is in range - have we already seen it?
        if discoveredPeripheral != peripheral {
            
            // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it.
            discoveredPeripheral = peripheral
            
            // And finally, connect to the peripheral.
            print("Connecting to perhiperal \(peripheral)")
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral Connected")
        
        // 스캔을 중단한다
        centralManager.stopScan()
        connectedPeripheral = peripheral
        // 검색 콜백을 받기위한 델리게이트 선언
        peripheral.delegate = self
        
        // UUID를 기준으로 서비스를 검색한다
        peripheral.discoverServices([serviceUUID])
    }
}
extension ContentViewModel: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        // 원하는 특성을 검색한다
        // 둘 이상의 서비스를 대비해 배열에 넣고 순환하여 탐색
        guard let peripheralServices = peripheral.services else { return }
        for service in peripheralServices {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // 에러처리
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        
        // 만약을 대비해 배열을 다시 순환시켜 특성이 맞는지 체크한다
        guard let serviceCharacteristics = service.characteristics else { return }
        for characteristic in serviceCharacteristics where characteristic.uuid == characteristicUUID {
            // 구독한다
            print("Subscribe Success...")
            peripheral.setNotifyValue(true, for: characteristic)
            self.characteristic = characteristic
            writeType = characteristic.properties.contains(.write) ? .withResponse :  .withoutResponse
        }
        
        sendMessageToDevice(id)
        // 여기까지 완료되었으면 데이터를 받는걸 기다린다
    }
}
