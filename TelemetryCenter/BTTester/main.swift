//
//  main.swift
//  BTTester
//
//  Created by Benno Krauss on 12.02.16.
//  Copyright © 2016 Benno Krauss. All rights reserved.
//

import Foundation
import CoreBluetooth




class BTTesterClass: NSObject, DZBluetoothSerialDelegate
{
	var clr: DZBluetoothSerialHandler!
	
	func BTTesterClass()
	{
	}
	
	func run()
	{
		clr = DZBluetoothSerialHandler(delegate: self)
		clr.delegate = self
		
		NSRunLoop.mainRunLoop().run()
	}
	
	
	/// Called when a message is received
	func serialHandlerDidReceiveMessage(message: String)
	{
		print("Did receive message: \(message)")
	}
	
	/// Called when de state of the CBCentralManager changes (e.g. when bluetooth is turned on/off)
	func serialHandlerDidChangeState(newState: CBCentralManagerState)
	{
		print("BT state changed to ")
		
		switch (newState)
		{
		case .Unknown:
			print("Unknown")
			break
		case .Resetting:
			print("Resetting")
			break
		case .Unsupported:
			print("Unsupported")
			break
		case .Unauthorized:
			print("Unauthorized")
			break
		case .PoweredOff:
			print("PoweredOff")
			break
		case .PoweredOn:
			print("PoweredOn")
			
			clr.scanForPeripherals()
			
			break
		}
	}
	
	/// Called when a new peripheral is discovered while scanning. Also gives the RSSI (signal strength)
	func serialHandlerDidDiscoverPeripheral(peripheral: CBPeripheral, RSSI: NSNumber)
	{
		print("Did find BT device: \(peripheral.name!)")
		if (peripheral.name! == "CC41")
		{
			dispatch_after(1, dispatch_get_main_queue(), { [unowned self] in
				self.clr.stopScanning()
				self.clr.connectToPeripheral(peripheral)
			})
		}
	}
	
	/// Called when a peripheral is connected (but not yet ready for cummunication)
	func serialHandlerDidConnect(peripheral: CBPeripheral)
	{
		print("Did connect to BT device: \(peripheral.name)")
	}
	
	/// Called when a peripheral disconnected
	func serialHandlerDidDisconnect(peripheral: CBPeripheral, error: NSError?)
	{
		print("Did disconnect from BT device: \(peripheral.name) error: \(error)")
		dispatch_after(1, dispatch_get_main_queue(), { [unowned self] in
			self.clr.scanForPeripherals()
		})
	}
	
	/// Called when a pending connection failed
	func serialHandlerDidFailToConnect(peripheral: CBPeripheral, error: NSError?)
	{
		print("Did fail to connect to BT device: \(peripheral.name) error: \(error)")
		dispatch_after(1, dispatch_get_main_queue(), { [unowned self] in
			self.clr.scanForPeripherals()
		})
	}
	
	/// Called when a peripheral is ready for communication
	func serialHandlerIsReady(peripheral: CBPeripheral)
	{
		print("Serial ready with BT device: \(peripheral.name)")
	}
}

BTTesterClass().run()

