//
//  BTController.swift
//  TelemetryCenter
//
//  Created by Benno Krauss on 12.02.16.
//  Copyright © 2016 Benno Krauss. All rights reserved.
//

import Foundation
import CoreBluetooth


@objc protocol BTControllerDelegate {
	func parsedPacket(p: BTPacket)
}

class BTController: NSObject, DZBluetoothSerialDelegate
{
	var clr: DZBluetoothSerialHandler!
	var buffer: String = ""
	var delegate: BTControllerDelegate!
	
	init(delegate: BTControllerDelegate!)
	{
		self.delegate = delegate
	}
	
	func run()
	{
		clr = DZBluetoothSerialHandler(delegate: self)
	}
	
	
	/// Called when a message is received
	func serialHandlerDidReceiveMessage(message: String)
	{
		//print("Did receive message: \(message)")
		
		buffer += message
		
		//print(message)
		tryParse()
	}
	
	private func tryParse()
	{
		while (buffer.containsString("#"))
		{
			/*
			struct BTPacket {
			uint32_t numberOfSatellites;
			uint32_t time;
			float speed;
			float longitude;
			float latitude;
			float altitude;
			int32_t hdop;
			float course;
			float temperature;
			float mainVoltage;
			float arduinoVoltage;
			}
			*/
			
			var p = BTPacket()
			
			let s = NSScanner(string: buffer)
			
			var temp: NSString?
			
			var success: Bool
			repeat { success = s.scanString("#", intoString: nil) } while (success == true);
			
			s.scanUpToCharactersFromSet(NSCharacterSet.decimalDigitCharacterSet(), intoString: nil)
			s.scanUpToString(",", intoString: &temp)
			p.numberOfSatellites = UInt32(temp!.longLongValue)
			s.scanString(",", intoString: nil)
			
			s.scanUpToString(",", intoString: &temp)
			p.time = UInt32(temp!.longLongValue)
			s.scanString(",", intoString: nil)
			
			s.scanUpToString(",", intoString: &temp)
			p.speed = Float(temp!.floatValue)
			s.scanString(",", intoString: nil)
			
			s.scanUpToString(",", intoString: &temp)
			p.longitude = Float(temp!.floatValue)
			s.scanString(",", intoString: nil)
			
			s.scanUpToString(",", intoString: &temp)
			p.latitude = Float(temp!.floatValue)
			s.scanString(",", intoString: nil)
			
			s.scanUpToString(",", intoString: &temp)
			p.altitude = Float(temp!.floatValue)
			s.scanString(",", intoString: nil)
			
			s.scanUpToString(",", intoString: &temp)
			p.hdop = Int32(temp!.intValue)
			s.scanString(",", intoString: nil)
			
			s.scanUpToString(",", intoString: &temp)
			p.course = Float(temp!.floatValue)
			s.scanString(",", intoString: nil)
			
			s.scanUpToString(",", intoString: &temp)
			p.temperature = Float(temp!.floatValue)
			s.scanString(",", intoString: nil)
			
			s.scanUpToString(",", intoString: &temp)
			p.mainVoltage = Float(temp!.floatValue)
			s.scanString(",", intoString: nil)
			
			s.scanUpToString("#", intoString: &temp)
			p.arduinoVoltage = Float(temp!.floatValue)
			s.scanString("#", intoString: nil)
			
			if (s.atEnd){
				buffer = ""
			}
			else {
				buffer = buffer.stringByReplacingCharactersInRange(Range<String.Index>(start:buffer.startIndex, end: buffer.startIndex.advancedBy(s.scanLocation)), withString: "")
			}
			//print("Leftover=" + buffer)
			
			BTPacketPrintDescription(&p);
		
			self.delegate.parsedPacket(p)
		}
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
	
	
	var peripherals = [CBPeripheral]()
	/// Called when a new peripheral is discovered while scanning. Also gives the RSSI (signal strength)
	func serialHandlerDidDiscoverPeripheral(peripheral: CBPeripheral, RSSI: NSNumber)
	{
		print("Did find BT device: \(peripheral.name!)")
		
		if (peripheral.name! == "CC41")
		{
			peripherals.removeAll()
			peripherals.append(peripheral)
			
			clr.stopScanning()
			clr.connectToPeripheral(peripheral)
		}
	}
	
	/// Called when a peripheral is connected (but not yet ready for cummunication)
	func serialHandlerDidConnect(peripheral: CBPeripheral)
	{
		buffer = ""
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