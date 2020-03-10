//
//  ViewController.swift
//  BLECentralMac
//
//  Created by RON LASSER on 1/21/20.
//  Copyright © 2020 RON LASSER. All rights reserved.
//

import Cocoa

import CoreBluetooth

/****************
 Make sure to add info.plist the entries:
 
 Privacy - Bluetooth Always Usage Description       The app needs bluetooth access...
 NSBluetoothPeripheralUsageDescriptor               The app needs bluetooth access...

otherwise app will not work
 */

let ecgService = CBUUID.init(string: "A22A3B82-63C4-4720-BF3A-6F5EF8CA42D4")
// characteristic has read/write
let ecgVal = CBUUID.init(string: "A22A3B82-63C4-4720-BF3A-6F5EF8CA42D4")

class ViewController: NSViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager!
    var myPeripheral: CBPeripheral!  // local copy of peripheral -- if forget -- warning from Xcode
    var ledState = "LightBulbOff"
    var ecgData = [Data]()

   override func viewDidLoad() {
       super.viewDidLoad()
       // Do any additional setup after loading the view.
       
       // Create central manager
       centralManager = CBCentralManager(delegate: self, queue: nil)
    
    // statements to use in tapped funcs to change values of characterisitcs
    // =====================================================================
    /*
    let bug: Data? = "LightBulbOff".data(using: .ascii)!
    let buggy = String.init(data: bug!, encoding: .ascii) ?? "No value"
    
    print("gulp: \(buggy)")
    print()
    */
   }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            
            central.scanForPeripherals(withServices: nil, options: nil) // general scan
            // central.scanForPeripherals(withServices: [advetisingData], options: nil) // for only data we are interested in

            print("scanning...")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name?.contains("ECG") == true {
            print(peripheral.name ?? "no name")
            //centralManager.stopScan()
            print("advertisement data: \(advertisementData)")
            central.connect(peripheral, options: nil)
            myPeripheral = peripheral // store local copy of peripheral
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected \(peripheral.name!)")
        peripheral.discoverServices(nil)
        peripheral.delegate = self
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        central.scanForPeripherals(withServices: nil, options: nil)  // general
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for svc in services {
                print("services: \(svc.uuid.uuidString)")
                peripheral.discoverCharacteristics(nil, for: svc)
            }
        }
    }
    var vibrationCharacteristic: CBCharacteristic? = nil
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let chars = service.characteristics {
            for char in chars {
                print("characteristics: \(char.uuid.uuidString)")
                if char.uuid == ecgVal {
                    /*if char.properties.contains(CBCharacteristicProperties.writeWithoutResponse) {
                        peripheral.writeValue(ledState.data(using: .ascii)!, for: char, type: CBCharacteristicWriteType.withoutResponse)
                        // peripheral.writeValue(Data.init(bytes: [01], count: 1), for: char, type: CBCharacteristicWriteType.withoutResponse)
                        }
                    else {
                         peripheral.writeValue(ledState.data(using: .ascii)!, for: char, type: CBCharacteristicWriteType.withResponse)
                        // peripheral.writeValue(Data.init(bytes: [01], count: 1), for: char, type: CBCharacteristicWriteType.withResponse)
                    }*/
                    
                    print(peripheral.readValue(for: char))
                }
                
                // peripheral.readValue(for: char)
                peripheral.setNotifyValue(true, for: char)

            }
        }
       /* guard let characteristics = service.characteristics
            else { print("Unable to retrieve service characteristics"); return }
        
        for characteristic in characteristics {
            print(characteristics)
            let name = characteristic.uuid.uuidString
            print(name)
            switch name {
            case "A22A3B82-63C4-4720-BF3A-6F5EF8CA42D4":
                print("sososos2")
                print("Available: Vibration")
                vibrationCharacteristic = characteristic
                let note = Notification(name: Notification.Name(rawValue: name))
                NotificationCenter.default.post(note)
            default:
                break
            }
            print("out of switch loop")
        }
        print("out of for loop")*/
    
        
    }
    func printmeoiushef() {
        print("me")
    }
    var values:[Int] = []
    var count = 0
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("help")
        if characteristic == ecgVal {
            print("here yo")
            count += 1
            let data = characteristic.value
            print("Count: \(count), data: \(data! as NSData)")


        
      }
            /*print("Peripheral did update characteristic value for " + characteristic.uuid.uuidString)
            
            guard let data = characteristic.value
                else { print("missing updated value"); return }
            print(data.count, "bytes received")
            
            switch characteristic.uuid.uuidString {
            case "FF0F":
                func evaluatePairing(_ data: Data) {
                    let result = data.withUnsafeBytes({ (ptr: UnsafePointer<Int16>) in
                        ptr.withMemoryRebound(to: Int16.self, capacity: 1) { pointer in
                            return pointer.pointee
                        }
                    })
                    print("Pairing result:", result)
                }

                evaluatePairing(data)
            default:
                break
            }*/
        
        
    }
    
    

    @IBAction func onTapped(_ sender: NSButton) {
        
        ledState = "LightBulbOn"
        print("ON")
        
        if let services = myPeripheral?.services {
            for svc in services {
                if svc.uuid == ecgService {
                    let service = svc
                    if let chars = service.characteristics {
                        for char in chars {
                            if char.uuid == ecgVal {
                                if char.properties.contains(CBCharacteristicProperties.writeWithoutResponse) {
                                    myPeripheral?.writeValue(ledState.data(using: .ascii)!, for: char, type: CBCharacteristicWriteType.withoutResponse)
                                    // myPeripheral?.writeValue(Data(bytes: [01], count: 1), for: char, type: .withoutResponse)
                                } else {
                                    myPeripheral?.writeValue(ledState.data(using: .ascii)!, for: char, type: CBCharacteristicWriteType.withResponse)
                                    // myPeripheral?.writeValue(Data(bytes: [01], count: 1), for: char, type: .withResponse)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func offTapped(_ sender: NSButton) {
        
        ledState = "LightBulbOff"
        print("OFF")
        
        if let services = myPeripheral?.services {
            for svc in services {
                if svc.uuid == ecgService {
                    let service = svc
                    if let chars = service.characteristics {
                        for char in chars {
                            if char.uuid == ecgVal {
                                if char.properties.contains(CBCharacteristicProperties.writeWithoutResponse) {
                                    myPeripheral?.writeValue(Data(bytes: [00], count: 1), for: char, type: .withoutResponse)
                                } else {
                                    myPeripheral?.writeValue(Data(bytes: [00], count: 1), for: char, type: .withResponse)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
 
    
    

}

